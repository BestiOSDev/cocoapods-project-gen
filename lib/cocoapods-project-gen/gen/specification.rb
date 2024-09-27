# frozen_string_literal: true
# AmberBin::BinSpecWithSource.generate()

module ProjectGen
  module BinSpecWithSource
    # class
    def self.generate(product, spec_hash)
      source_base_url = "http://127.0.0.1:8081/frameworks"
      # source源
      binary_source = { http: format("#{source_base_url}/%s/%s/%s", product.xcframework_name, product.version, product.zip_product_name) }
      delete_common_properties(product, spec_hash)
      # 二进制 --》xcframework[ .a .framework]
      # 存放库要携带的二进制
      # vendored_libraries = .a .dylib
      key = :vendored_frameworks
      name = 'BinProduct'
      spec = Pod::Specification.from_hash(spec_hash)

      # subspec
      spec.subspecs.each do |s|
        s.dependency("#{spec.name}/#{name}")
      end
      spec.subspec(name) do |s|
        s.preserve_paths = [product.xcframework_product_name]
        s.send("#{key}=", [product.xcframework_product_name])
        # import = {
        #     'OTHER_SWIFT_FLAGS' => "-Xcc -fmodule-map-file=\"${PODS_XCFRAMEWORKS_BUILD_DIR}/#{product.xcframework_name}/BinProduct/Headers/#{product.xcframework_name}/#{product.xcframework_name}.modulemap\"",
        #     'OTHER_CFLAGS' => "-fmodule-map-file=\"${PODS_XCFRAMEWORKS_BUILD_DIR}/#{product.xcframework_name}/BinProduct/Headers/#{product.xcframework_name}/#{product.xcframework_name}.modulemap\""
        # }
        # if product.uses_swift? && !product.build_as_framework?
        #     import.merge!({ 'SWIFT_INCLUDE_PATHS' => "\"${PODS_XCFRAMEWORKS_BUILD_DIR}/#{product.xcframework_name}/BinProduct/Headers\"" })
        # end
        # moudle --> app -->hook
        # podfile use_moduler_header!
        # .a -->module --> hook -->
        # s.user_target_xcconfig = import
      end
      spec.subspecs.reverse!
      spec.default_subspecs = [name, spec.default_subspecs].compact.flatten
      spec.source = binary_source
      spec.version = "#{product.version}-binary"
      spec.description = <<-EOF
            name: #{product.xcframework_name}
            version: #{product.version}
            组件二进制化
            #{product.root_spec.description}
      EOF

      path = product.bin_spec_path
      contents = spec.to_pretty_json
      if path.exist?
        content_stream = StringIO.new(contents)
        identical = File.open(path, 'rb') { |f| FileUtils.compare_stream(f, content_stream) }
        return nil if identical
      end
      File.open(path, 'w+') { |f| f.write(contents) }
      return path
    end

    # ruby --json -->删掉--》podspec --》老基础上
    def self.delete_common_properties(product, attributes)
      attributes.delete('source_files')
      attributes.delete('script_phases')
      attributes.delete('script_phase')
      attributes.delete('module_map')
      attributes.delete('header_mappings_dir')
      attributes.delete('preserve_paths')
      attributes.delete('pod_target_xcconfig')
      attributes.delete('compiler_flags')
      attributes.delete('prepare_command')
      attributes.delete('exclude_files')
      unless product.build_as_framework?
        attributes.delete('public_header_files')
        attributes.delete('private_header_files')
      end
      attributes['subspecs'].each { |s| delete_common_properties(product, s) } unless attributes['subspecs'].nil?
    end
  end
end


