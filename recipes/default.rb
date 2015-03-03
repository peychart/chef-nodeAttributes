#
# Cookbook Name:: chef-serviceAttributes
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
  raise unless if secret_key
       if secret_key.is_a? String
            databag = Chef::EncryptedDataBagItem.load( name, item.gsub('.', '_'), Chef::EncryptedDataBagItem.load_secret( secret_key ) ).to_hash
       else databag = Chef::EncryptedDataBagItem.load( name, item.gsub('.', '_') ).to_hash
       end
  else databag = data_bag_item( name, item.gsub('.', '_') )
  end
  rescue Exception
    puts '********************************************************************'
    puts "No such a data bag: '#{name}' or item: '#{item}'..."
    puts '********************************************************************'
    return nil
  ensure
  end
  databag
end

def getDatabagsNames( v )
  databagName = ""
  servName = []
  if v.is_a? Hash
        v.each do |n,i|; if n != "precedence" && n != "secret_key" # Nerver use these names... ;-)
          databagName = n
          getDatabagsNames( i ).each do |n, j|; servName.concat( j ); end
        end; end
  elsif v.is_a? Array
        v.each do | i |; getDatabagsNames( i ).each do |n, j|; servName.concat( j ); end; end
  else  servName.push( v )
  end
  Hash[ databagName, servName ]
end

getDatabagsNames( node['chef-serviceAttributes'] ).each do |n, i|
  i.each do |j|
    $getEnv.call( node.default, getDataBag( n, j, node['chef-serviceAttributes']['secret_key'] ) )
  end
end

case node['chef-serviceAttributes']['precedence']
  when 'force_default'  then node.force_default  = node.default
  when 'force_override' then node.force_override = node.default
  when 'normal'         then node.normal         = node.default
  when 'override'       then node.override       = node.default
  when 'force_override' then node.force_override = node.default
  when 'automatic'      then node.automatic      = node.default
end
