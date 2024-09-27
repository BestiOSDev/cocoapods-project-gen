# require 'cocoapods/resolver/lazy_specification'
#
# module Pod
#   class Podfile
#     module AmberBin
#       # Removes :modular_headers from the requirements list, and adds
#       # the pods name into internal hash for modular headers.
#       #
#       # @param [String] name The name of the pod
#       #
#       # @param [Array] requirements
#       #        If :modular_headers is the only key in the hash, the hash
#       #        should be destroyed because it confuses Gem::Dependency.
#       #
#       # @return [void]
#       #
#       def parse_use_binaries(name, requirements)
#         options = requirements.last
#         if options.is_a?(Hash)
#           use_binaries = options.delete(:use_binaries)
#           pod_name = Specification.root_name(name)
#           requirements.pop if options.empty?
#           use_binaries
#         end
#       end
#
#       def handle_binaries(name, requirements)
#         options = requirements.last
#         need_additional_source = if options.is_a?(Hash)
#                                    options[:podspec].nil? && options[:source].nil?
#                                  else
#                                    true
#                                  end
#         need_binaries = parse_use_binaries(name, requirements) || internal_hash.fetch('use_binaries', false)
#         use_binaries = need_additional_source && need_binaries
#         if use_binaries
#           dependency = Dependency.new(name, *requirements)
#           source = Config.instance.sources_manager.sources([Config.instance.repos_dir + 'binary_repo']).first
#           specifications = source.search(dependency)
#           unless specifications.nil?
#             # build_type = current_target_definition.build_type
#             specification = specifications.all_specifications(nil, dependency.requirement).first
#             pod_path = specification.spec_source.pod_path(name)
#             unless pod_path.nil?
#               specification_path = pod_path.join(specification.version.to_s, "#{name}.podspec")
#               unless File.exist?(specification_path)
#                 specification_path = pod_path.join(specification.version.to_s,
#                                                    "#{name}.podspec.json")
#               end
#               if File.exist?(specification_path)
#                 if options.is_a?(Hash)
#                   options[:podspec] = specification_path
#                 else
#                   requirements << { podspec: specification_path }
#                 end
#               else
#                 raise "binrary repo not contain #{name} #{version} pod repo update!"
#               end
#             end
#           end
#         end
#       end
#
#       module DSL
#         def use_binaries!
#           internal_hash['use_binaries'] = true
#         end
#       end
#     end
#   end
# end
