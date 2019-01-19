# puppet_ipsec
Full mesh IPSec network with preshared keys with Puppet and racoon

Edit $vpnconf and $vpnsecrets according to your needs

You should always have exactly (number_of_hosts) * (number_of_hosts - 1) / 2 secrets - a full-mesh network is C(2,k) combination

The code in the beginning builds the combination of the secrets in $vpnsecretsarray, rest if self-explanatory.
