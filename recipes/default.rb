#
# Cookbook Name:: chef-haclusters
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

#def openDatBagItem( name, item )
#begin
#  raise unless data= data_bag_item( name, item )
#  rescue Exception
#    puts '********************************************************************************'
#    puts "No databag definition: #{name}(#{item})..."
#    puts '********************************************************************************'
#    return
#  ensure
#    #
#end
#data
#end

if node['databag_name'].is_a? Array
  node['databag_name'].each do |i|
    return 1 if ! i = data_bag_item( i, node['fqdn'].gsub(".", "_") )
    if node['mode'] == 'override'
          context = getEnv( context, i )
    else  context = addEnv( context, i )
    end
  end
else
  return 1 if ! context = data_bag_item( node['databag_name'], node['fqdn'].gsub(".", "_") )
end

def getEnv( context, val, merge )
  val.each do |name, val|
    if val.is_a? Hash
      if !merge || !(context.is_a? Hash)
        context[name] = val
      else
        context[name] = getEnv( context[name], val, merge )
      end
    else
      if val.is_a? Array
        if !context[name] || !merge || !(context[name].is_a? Array)
          context[name]  = val
        else
          context[name] += val
        end
      else
        context[name] = val if !context[name] || context[name]=={} || !merge
      end
    end
  end
  context
end

node.default = getEnv( node.default, context, node['mergeMode'] )
