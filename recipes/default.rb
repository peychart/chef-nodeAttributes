#
# Cookbook Name:: chef-nodeAttributes
# Recipe:: default
#
# Copyright (C) 2014 PE, pf.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# PE-20140916

$getEnv= lambda { |context, val|
  val.each do |n, v|
    if v.is_a? Hash
      if ( n[0]=='!' || context[ n[0]=='!' ? n[1..-1] : n ]=={} )
           context[ n[0]=='!' ? n[1..-1] : n ] = v
      else context[ n[0]=='!' ? n[1..-1] : n ] = $getEnv.call( context[ n[0]=='!' ? n[1..-1] : n ], v )
      end
    elsif v.is_a? Array
      context[ n[0]=='!' ? n[1..-1] : n ] = Array( n[0]=='!' ? [] : context[ n ] ) + v
    else
      context[ n[0]=='!' ? n[1..-1] : n ] = v
    end
  end
  context
}

if node['chef-nodeAttributes']['databag_name'].is_a? Array
  node['chef-nodeAttributes']['databag_name'].each do |i|
    if node['chef-nodeAttributes']['secret_key']
         if node['chef-nodeAttributes']['secret_key'].is_a? String
              return 1 if ! i = Chef::EncryptedDataBagItem.load( i, node['fqdn'].gsub('.', '_'), Chef::EncryptedDataBagItem.load_secret( node['chef-nodeAttributes']['secret_key'] ) )
         else return 1 if ! i = Chef::EncryptedDataBagItem.load( i, node['fqdn'].gsub('.', '_') )
         end
    else return 1 if ! i = data_bag_item( i, node['fqdn'].gsub('.', '_') )
    end
    $getEnv.call( context, i )
  end
else
  if node['chef-nodeAttributes']['secret_key']
    if node['chef-nodeAttributes']['secret_key'].is_a? String
         return 1 if ! i = Chef::EncryptedDataBagItem.load( i, node['fqdn'].gsub('.', '_'), Chef::EncryptedDataBagItem.load_secret( node['chef-nodeAttributes']['secret_key'] ) )
    else return 1 if ! i = Chef::EncryptedDataBagItem.load( i, node['fqdn'].gsub('.', '_') )
    end
  else return 1 if ! context = data_bag_item( node['chef-nodeAttributes']['databag_name'], node['fqdn'].gsub('.', '_') )
  end
  $getEnv.call( node.default, context )
end

case node['chef-nodeAttributes']['precedence']
  when 'force_default'  then node.force_default  = node.default
  when 'force_override' then node.force_override = node.default
  when 'normal'         then node.normal         = node.default
  when 'override'       then node.override       = node.default
  when 'force_override' then node.force_override = node.default
  when 'automatic'      then node.automatic      = node.default
end
