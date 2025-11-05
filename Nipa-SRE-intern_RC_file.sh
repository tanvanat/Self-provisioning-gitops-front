#!/usr/bin/env bash
# To use NIPA Cloud Space public API you need to authenticate against the Identity
# service named keystone, which returns a **Token** and **Service Catalog**.
# The catalog contains the endpoints for all services the user/project has
# access to - such as Compute Instance, Compute Image, Block Storage, Networking.

export OS_AUTH_URL=https://identity-api.nipa.cloud/
# Co-working project identity
export OS_PROJECT_ID=dda823844b244c11baa2a5a272c78ee9
export OS_PROJECT_NAME="Nipa-SRE-intern"
export OS_USER_DOMAIN_NAME="nipacloud"
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID="c6b00adf4ed04fc5a958121fadb0e401"
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
# unset v2.0 items in case set
unset OS_TENANT_ID
unset OS_TENANT_NAME
# performing the action as the **user**.
export OS_USERNAME="tanvanat@nipa.cloud"
echo "Please enter your NIPA Cloud Space user's password for project $OS_PROJECT_NAME as user $OS_USERNAME: "
read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
# NIPA Cloud Space only have 1 region "NCP-TH"
export OS_REGION_NAME="NCP-TH"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
