
/*
    These are the credentials used to login to CCP
*/
variable "ccpUser" {}
variable "ccpPass" {}
variable "ccpURL" {}
/*
    These are the CCP Cluster Information
*/

variable "ccpClusterName" {}
variable "apicHosts" {}
variable "apicUser" {}
variable "apicPass" {}
variable "ccpProviderID" {}
variable "k8sVersion" {}
variable "k8sTemplate" {}
variable "ccpSshUser" {}
variable "ccpSshKey" {}

/*
    This is the ACI Application Profile Information
*/

variable "appProfile" {}
variable "hipsterContracts" {
    type = list(object({
        name = string,
        port = number,
        provide = string,
        consume = list(string)
    }))
}