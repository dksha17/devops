import requests
import os
import sys

## Token(bearer_all_vaults_token) for listing all the existing vaults.
data = {
'grant_type': 'client_credentials',
'client_id': '',
'client_secret': '',
'resource': 'https://management.azure.com/'
}
all_vaults = requests.post('https://login.microsoftonline.com//oauth2/token', data=data)
all_vaults_token = all_vaults.json()
bearer_all_vaults_token = all_vaults_token["access_token"]

#print("==================================================")

## Token(bearer_individual_vault_info_token) for processing the vaults.
data = {
  'grant_type': 'client_credentials',
  'client_id': '',
'client_secret': '',
  'resource': 'https://vault.azure.net\n'
}
vault_info = requests.post('https://login.microsoftonline.com/b7f604a0-00a9-4188-9248-42f3a5aac2e9/oauth2/token', data=data)
individual_vault_info = vault_info.json()
bearer_individual_vault_info_token = individual_vault_info["access_token"]

#print("==================================================")

## Using bearer_all_vaults_token list the existing vault names.
headers = {
    'Authorization': 'Bearer %s' %bearer_all_vaults_token,
}
params = (
    ('api-version', '2015-06-01'),
)
vaults = requests.get('https://management.azure.com/subscriptions/3b4e7911-7da5-4369-bf15-24e39bfad109/resourceGroups/platform_esgh_keyvault_rg/providers/Microsoft.KeyVault/vaults', headers=headers, params=params)
vault_name = vaults.json()
p = vault_name["value"] ## "P" will hold the entire valut JSON as a LIST
lst=[]
lst_vault=[]
## Iterating "P" and extracting the vault name "val"
for i in range(len(p)):
    val = p[i]["id"].split("/")[-1]
    #print("Secrets extracting from %s vault" %val)
    headers = {
        'Authorization': 'Bearer %s' %bearer_individual_vault_info_token,
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2016-10-01'),
    )
    response3 = requests.get('https://%s.vault.azure.net/secrets'% val, headers=headers, params=params)
    resp3 = response3.json()
    x3 = resp3["value"]
    for k in range(len(x3)):
        id1 = x3[k]["id"]
        id2 = x3[k]["id"].split("/")[-1]
        #print("Secret Name is : %s" %id2)
        headers = {
        'Authorization': 'Bearer %s' %bearer_individual_vault_info_token,
        'Content-Type': 'application/json',
        }
        params = (
        ('api-version', '2016-10-01'),
        )
        response4 = requests.get('%s' %id1, headers=headers, params=params)
        x4 = response4.json()
        val5 = x4["value"]
        #print("Secret of %s is : %s"%(id2 , val5))
        #print("==================================================")
        con = "%s__%s"%(val,id2)
        lst.append(val5)
        lst_vault.append(con)
key_value = dict(zip(lst_vault,lst))
#print("The secret for selected SECRET '%s' is : %s"% (sys.argv[1] , key_value[str(sys.argv[1])]))
print(key_value[str(sys.argv[1])])
#print(key_value[str(sys.argv[1])])
