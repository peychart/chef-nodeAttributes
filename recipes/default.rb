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

$getEnv= lambda { |context, val, merge|
  val.each do |name, v|
    if v.is_a? Hash
      if !(context.is_a? Hash)
        context[name] = v
      else
        context[name] = $getEnv.call(context[name], v, merge)
      end
    elsif v.is_a? Array
      if !context[name] || !merge || !(context[name].is_a? Array)
        context[name]  = v
      else
        context[name] += v
      end
    else
      context[name] = v if !context[name] || context[name] == {} || !merge
    end
  end
  context
}

if node['chef-nodeAttributes']['databag_name'].is_a? Array
  node['chef-nodeAttributes']['databag_name'].each do |i|
    return 1 if ! i = data_bag_item(i, node['fqdn'].gsub('.', '_'))
    context = $getEnv.call(context, i, node['chef-nodeAttributes']['mergeMode'])
  end
else
  return 1 if ! context = data_bag_item(node['chef-nodeAttributes']['databag_name'], node['fqdn'].gsub('.', '_'))
  node.default = $getEnv.call(node.default, context, node['chef-nodeAttributes']['mergeMode'])
end

case node['chef-nodeAttributes']['precedence']
  when 'force_default'  then node.force_default  = node.default
  when 'force_override' then node.force_override = node.default
  when 'normal'         then node.normal         = node.default
  when 'override'       then node.override       = node.default
  when 'force_override' then node.force_override = node.default
  when 'automatic'      then node.automatic      = node.default
end
