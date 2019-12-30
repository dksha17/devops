echo "Enter the repo name"

#read repo

echo "Enter the GHE owner or organization name"

#read owner

curl  -v -H "Content-Type: application/json" -H "Authorization: bearer $token" -X POST -d '{"name": "'"$repo"'", "private": true, "homepage": "'"$target_github_url"'"}' $target_github_url/api/v3/orgs/"${target_organization}"/repos



echo "Enter the github onwer or org name"

#read source_git_organization

echo "Enter the github repo to clone into local"

#read git_repo

echo "Enter the username of Github user"

#read git_user

echo "Enter the github user token"

#read git_token

git clone https://$git_user:$source_git_user_token@github.com/"${source_git_organization}"/"${repo}".git --bare

sleep 10

cd $repo.git

value=$(echo "$target_github_url" | cut -d '/' -f3)

git remote add enterprise https://esd00gh:"${token}"@$value/"${target_organization}"/"${repo}.git"

git push enterprise --mirror
