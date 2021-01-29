provider "aci" {
    username = var.apicUser
    password = var.apicPass
    url      = "https://192.168.64.84"
    insecure = true
}

resource "aci_contract" "hipsterContracts" {
        
    tenant_dn   = "uni/tn-${var.ccpClusterName}"
    for_each                = {for epg in var.hipsterContracts: epg.name => epg}

    name                    = "${each.value.name}"
    scope = "tenant"
        filter {
            filter_entry {
                filter_entry_name = "${each.value.name}"
                    d_to_port = "${each.value.port}"
                    d_from_port = "${each.value.port}"
                    ether_t = "ipv4"
                    prot = "tcp"  
            }
        filter_name = "${each.value.name}"
        }
}

resource "aci_contract_subject" "hipsterSubjectAdd" {

    for_each                = {for epg in var.hipsterContracts: epg.name => epg}

    contract_dn   = "uni/tn-${var.ccpClusterName}/brc-${each.value.name}"
    name                    = "${each.value.name}"

    relation_vz_rs_subj_filt_att = ["uni/tn-${var.ccpClusterName}/flt-${each.value.name}"]
    depends_on = [aci_contract.hipsterContracts]
}

resource "aci_application_profile" "hipster" {
  tenant_dn   = "uni/tn-${var.ccpClusterName}"
  name        = "${var.appProfile}"
  description = "This app profile is created by terraform for the ${var.appProfile}"
}

resource "aci_application_epg" "hipsterApplication_epg" {
    application_profile_dn  = "${aci_application_profile.hipster.id}"
    
    for_each                = {for epg in var.hipsterContracts: epg.name => epg}

    name                    = "${each.value.name}"
    relation_fv_rs_bd       = "BD-kube-pod-bd"
    relation_fv_rs_sec_inherited = ["uni/tn-${var.ccpClusterName}/ap-kubernetes/epg-kube-default"]    
    relation_fv_rs_cons = [
        for cons in each.value.consume:
            "uni/${var.ccpClusterName}/brc-${cons}"
            if cons != ""
        
    ]
    relation_fv_rs_prov = ["uni/${var.ccpClusterName}/brc-${each.value.provide}"]
}
