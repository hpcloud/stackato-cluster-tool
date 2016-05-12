# Import your SSH public key into OpenStack and set the ssh_key_name variable
# Have your OpenStack credentials setup (tested):
# * Using the variables defined in this file:
#     os_auth_url, os_tenant_name, os_username, os_password and os_region_name
#
# * Using the OpenStack web console (not tested):
#     1. Login to the OpenStack web console
#     2. On the left menu, click on Project > Compute > Access & Security
#     (direct link: https://your_openstack.com/project/access_and_security/),
#     then click on the tab "API Access". From that page, you can download
#     the OpenStack RC file by click on the button "Download OpenStack RC file".
#     3. Source the OpenStack RC file to import the variables
#
# * Set the environment variables manually (not tested):
#     OS_AUTH_URL=https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/
#     OS_REGION_NAME=region-b.geo-1
#     OS_TENANT_NAME=hpcs@activestate.com-tenant1
#     OS_USERNAME=stefanb
#     OS_PASSWORD='your password'
#
variable os_region_name {
  description = "Region to deploy each node"
  default = "region1"
}

variable ssh_key_name {
  description = "SSH key name used to connect to instances"
  default = "stefan-win-key"
}

variable openstack_flavor_name {
  description = "OpenStack flavor ID for each node type"
  default = {
    proxy = "standard.large"
    core = "standard.large"
    dea = "standard.large"
    dataservices = "standard.large"
    controller = "standard.large"
    router = "standard.large"
  }
}

# To get the value, run the neutron cli command on an existing configured router:
# neutron router-show ROUTER_NAME
variable external_gateway_uuid {
  description = "The UUID of the external gateway that the router will connect to reach internal"
  default = "7da74520-9d5e-427b-a508-213c84e69616"
}

variable floating_ip_pool_name {
  description = "The name of the floating IPs pool that will be used to attach to public facing nodes"
  default = "Ext-Net"
}
