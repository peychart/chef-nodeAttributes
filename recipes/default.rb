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
  end if val
  context
}

def getDataBag( name, item, secret_key )
  begin
  if secret_key
       if secret_key.is_a? String
            raise unless databag = Chef::EncryptedDataBagItem.load( name, item.gsub('.', '_'), Chef::EncryptedDataBagItem.load_secret( secret_key ) )
       else raise unless databag = Chef::EncryptedDataBagItem.load( name, item.gsub('.', '_') )
       end
  else raise unless databag = data_bag_item( name, item.gsub('.', '_') )
  end
  rescue Exception
    puts '********************************************************************'
    puts "No such a data bag or role for the node #{node['fqdn']}..."
    puts '********************************************************************'
    return nil
  ensure
  end
  databag
end

if node['chef-nodeAttributes']['databag_name'].is_a? Array
  node['chef-nodeAttributes']['databag_name'].each do |i|
     $getEnv.call( node.default, getDataBag( i, node['fqdn'], node['chef-nodeAttributes']['secret_key'] ) )
  end
else i = node['chef-nodeAttributes']['databag_name']
     $getEnv.call( node.default, getDataBag( i, node['fqdn'], node['chef-nodeAttributes']['secret_key'] ) )
end

case node['chef-nodeAttributes']['precedence']
  when 'force_default'  then node.force_default  = node.default
  when 'force_override' then node.force_override = node.default
  when 'normal'         then node.normal         = node.default
  when 'override'       then node.override       = node.default
  when 'force_override' then node.force_override = node.default
  when 'automatic'      then node.automatic      = node.default
end
