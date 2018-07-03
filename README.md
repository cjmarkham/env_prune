# ENV Prune
Find out which ENV variables can be removed from your .env file

**Warning** The ENV variables listed are just ones that are unused in your code. Some ENV variables could be used by other third party applications such as Rails gems. Always make sure they aren't used by another application before removing.

# Usage
`ruby env_prune.rb`


# Arguments

#### -d Comma seperated list of directories to search
`-d=app,config`

#### -f Comma seperated list of file extensions to search
`-f=rb,html`

#### -e The name of the env file
`-e=.env`
