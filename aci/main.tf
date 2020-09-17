provider "aci" {
    username = var.apicUser
    password = var.apicPass
    url      = "https://${apicHosts}"
    insecure = true
}

resource "aci_contract" "hipsterContracts" {
        
    tenant_dn   = "uni/tn-${var.ccpClusterName}"
        count = "${length(keys(var.contracts))}"

        name = "${element(keys(var.contracts), count.index)}"
        scope = "tenant"
        
            filter {
                filter_entry {
                    filter_entry_name = "${element(keys(var.contracts), count.index)}"
                        d_from_port = "${element(values(var.contracts), count.index)}"
                        ether_t = "ipv4"
                        prot = "tcp"  
                }
            filter_name = "${element(keys(var.contracts), count.index)}"
            }
}

resource "aci_contract_subject" "hipsterSubjectAdd" {
    count = "${length(keys(var.contracts))}"
    contract_dn   = "uni/tn-tiger/brc-${element(keys(var.contracts), count.index)}"
    name          = "${element(keys(var.contracts), count.index)}"
    relation_vz_rs_subj_filt_att = ["uni/tn-tiger/flt-${element(keys(var.contracts), count.index)}"]
    depends_on = [aci_contract.hipsterContracts]
}

resource "aci_application_profile" "hipster" {
  tenant_dn   = "uni/tn-${var.ccpClusterName}"
  name        = "hipster"
  description = "This app profile is created by terraform"
}

resource "aci_application_epg" "hipsterApplication_epg" {
    application_profile_dn  = "${aci_application_profile.hipster.id}"
    
    for_each                = {for epg in var.hipsterContracts: epg.name => epg}
    # count                   = length(var.epgs)
    name                    = "${each.value.name}"
    relation_fv_rs_bd       = "BD-kube-pod-bd"
    relation_fv_rs_sec_inherited = ["uni/tn-${var.ccpClusterName}/ap-kubernetes/epg-kube-default"]    
    relation_fv_rs_cons = ["uni/tn-tiger/brc-${each.value.consume}"]
    relation_fv_rs_prov = ["uni/tn-tiger/brc-${each.value.provide}"]
}