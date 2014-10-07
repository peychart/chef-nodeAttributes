# chef-nodeAttributes-cookbook

 This chef cookbook allows to simulate node environments in node definitions by the use of data bags...

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
    <td><tt>['chef-nodeAttributes']['databag_name']</tt></td>
    <td>String/StringArea</td>
    <td>where found the fqdn item</td>
    <td><tt>nodes</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-nodeAttributes']['mergeMode']</tt></td>
    <td>Boolean</td>
    <td>merge env or override when existing</td>
    <td><tt>TRUE</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-nodeAttributes']['precedence']</tt></td>
    <td>String</td>
    <td>Precedence to apply in the next run</td>
    <td><tt>normal (see: https://docs.getchef.com/essentials_cookbook_attribute_files.html#attribute-types)</tt></td>
  </tr>
</table>

## Usage

 Default attributes can be definied in a data bag whose items are the fqdn of the nodes. Then, an other cookbook can be applied...

 (1): Dots are not allowed (only alphanumeric), substitute by underscores

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


### chef-nodeAttributes::default

Include `chef-nodeAttributes` in your node's `run_list`:

```json
{
  "override_attributes" => {
    "chef-nodeAttributes" => {
      "databag_name" => "clusters"
    }
  },
  "run_list" => [
    "other.chef-nodeAttributes::default",
    "other.chef-cookbook::recipe"
  ]
}
```

 So, node.default is then settled from the data bag definitions, on the item "fqdn" of the node; then node.'precedence' = node.default. An other cookbook::recipe can be applied...

## License and Authors

Author:: PE, pf. (<peychart@mail.pf>)
