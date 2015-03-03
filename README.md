# chef-serviceAttributes-cookbook

 This chef cookbook allows to simulate service environments in service definitions by the use of data bags...

## Supported Platforms

 ubuntu/debian

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef-serviceAttributes']['precedence']</tt></td>
    <td>String</td>
    <td>Precedence to apply in the next run</td>
    <td><tt>normal (see: https://docs.getchef.com/essentials_cookbook_attribute_files.html#attribute-types)</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-serviceAttributes']['secret_key']</tt></td>
    <td>String/boolean</td>
    <td>location of the encryption key (TRUE for default)</td>
    <td><tt>FALSE</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-serviceAttributes'][*]</tt></td>
    <td>String/StringArea</td>
    <td>Data bag where to found the fqdn item</td>
    <td><tt>nil</tt></td>
  </tr>
</table>

## Usage

 Default attributes of any cookbook called after this one can be completed within data bags whose items are the service id...

 In these data bags, when an attribute name is preceded with '!', all initial values of arrays or hashs are deleted before update.

 (1): Dots are not allowed in databags items (only alphanumeric); must be substitute by underscores...

eg:
<pre>
{
  "id": "ldap2_toriki_dmz_srv_gov_pf",
  "haproxy":{
    "services":{
      "ldap_cluster":{
        "app_server_role": "toriki.dmz.srv",
        "pool_members":[{
          "hostname":"ldap2",
          "ipaddress":"ldap2.toriki.dmz.srv.gov.pf",
          "member_port":"390",
          "member_options":"check port 5667 inter 2s fall 5 rise 1"
        }]
      }
    }
  },
  "iproute2":{}
}
{
  "id": "ldap_toriki_dmz_srv_gov_pf",
  "haproxy": {
    "httpchk": "HEAD",
    "services": {
      "ldap_cluster": {
        "app_server_role": "toriki.dmz.srv",
        "httpchk": "HEAD",
        "mode": "tcp",
        "balance": "leastconn",
        "incoming_address": "0.0.0.0",
        "incoming_port": "389"
      }
    }
  },
  "iproute2": {}
}
{
  "id": "ldap1_toriki_dmz_srv_gov_pf",
  "haproxy":{
    "services":{
      "ldap_cluster":{
        "app_server_role": "toriki.dmz.srv",
        "pool_members":[{
          "hostname":"ldap1",
          "ipaddress":"ldap1.toriki.dmz.srv.gov.pf",
          "member_port":"390",
          "member_options":"check port 5667 inter 2s fall 5 rise 1"
        }]
      }
    }
  },
  "iproute2":{}
}
{
  "id": "loadbalancer_dev_gov_pf",
  "iproute2":{
  },
  "haproxy":{
    "services": {
      "ldap_cluster": {
        "app_server_role": "",
        "incoming_address": "0.0.0.0",
        "incoming_port": "389",
        "mode": "tcp",
        "httpchk": "HEAD",
        "balance": "leastconn",
        "pool_members": [{
          "hostname": "ldapwrite",
          "ipaddress": "ldapwrite.srv.gov.pf",
          "member_port": "390",
          "member_options": "check port 5667 inter 2s fall 5 rise 1"
        },{
          "hostname": "ldapsecond",
          "ipaddress": "ldapsecond.srv.gov.pf",
          "member_port": "390",
          "member_options": "check port 5667 inter 2s fall 5 rise 1"
        },{
          "hostname": "ldapdmz",
          "ipaddress": "ldapdmz.srv.gov.pf",
          "member_port": "389",
          "member_options": "check addr localhost port 5667 inter 2s fall 5 rise 1 backup"
        }]
      }
    }
  }
}
</pre>


### chef-serviceAttributes::default

Include `chef-serviceAttributes` in your node's `run_list`:

```json
{
  "override_attributes" => {
    "chef-serviceAttributes" => {
      "myDatabagName" => "clusters"    // Can be a stringsArray...
    }
  },
  "run_list" => [
    "other.chef-serviceAttributes::default",
    "other.chef-cookbook::recipe"
  ]
}
```

WARNING: don't use the same attribut name between succesive roles to define the databag name(s)

 So, node.default is then settled from the data bag definitions, on the item "name of the role"; then node.'precedence' = node.default. An other cookbook::recipes can be applied...

## License and Authors

Author:: PE, pf. (<peychart@mail.pf>)
