import requests

USER_REPOS_URL = "https://api.github.com/users/awoisoak/repos"

response = requests.get(USER_REPOS_URL)
my_repos = response.json()

for repo in my_repos:
    if not repo["fork"]:
        print(f'{repo["name"]}\n{repo["url"]}')
