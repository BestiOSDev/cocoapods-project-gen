# require 'cocoapods-core/podfile'
# require 'cocoapods-project-gen/gen/podfile/dsl'
#
# module Pod
#   class Podfile
#     include AmberBin
#     include AmberBin::DSL
#
#     alias orgi_pod pod
#     def pod(name = nil, *requirements)
#       raise StandardError, 'A dependency requires a name.' unless name
#
#       handle_binaries(name, requirements)
#       orgi_pod(name, *requirements)
#     end
#   end
# end