# aaws

`aaws` allows you to switch between your AWS accounts and ssh into hosts by
their EC2 name tag.

## How it works

`aaws` sets the `AWS_PROFILE` environment variable sourced directly from your
`~/.aws/credentials` file.

```
~/ $ aaws luk3
[luk3] 🔐 ~/ $
```

Now you're able to interact with the `aws` CLI

```
[luk3] 🔐 ~/ $ aws s3 ls
2013-11-05 21:40:04 luk3thomas.com
```

Or you can ssh into EC2 hosts using `assh`

```
[luk3] 🔐 ~/ $ assh luke.thomas@envoy
1) 172.1.1.7        envoy-2-staging
2) 172.1.1.4        envoy-3-staging
3) 172.1.1.5        envoy-1-staging
#?
```

When you're done you can unset your AWS profile by running aaws without any
arguments

```
[luk3] 🔐 ~/ $ aaws
~/ $
```

## Installation

Clone the repo to your home directory

```
git clone git@github.com:luk3thomas/aaws.git ~/.aaws
```

Load the `aaws` command into your `~/.bashrc` or `~/.bash_profile`

```
if [ -s $HOME/.aaws/aaws.sh ]; then
  source $HOME/.aaws/aaws.sh
fi
```

### zsh

The script may require extra dependencies to successfully load aaws.

```
autoload -U bashcompinit; bashcompinit
autoload -U compinit; compinit
```
