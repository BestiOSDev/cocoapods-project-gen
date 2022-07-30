require 'cocoapods-project-gen/gen/product_helper'

module ProjectGen
  class Products
    attr_reader :products

    def initialize(targets, product_root, archive_paths, root)
      @products = targets.map do |target|
        Product.new(target, product_root, archive_paths, root)
      end
      @root = root
    end

    def add_pod_targets_file_accessors_paths
      products.each(&:add_pod_target_file_accessors_paths)
    end

    def create_bin_products
      products.each(&:create_bin_product!)
    end
  end

  class Product
    include ProductHelper

    attr_reader :target, :product_root

    def initialize(target, product_root, archive_paths, root)
      @target = GenTarget.new(target)
      @archive_paths = archive_paths
      @product_root = product_root
      @root = root
    end

    def create_bin_product!
      $stdout.puts "[xcframework]: #{xcframework_product_path}".green
      build_xcframework!
    end

    def add_pod_target_file_accessors_paths
      add_vendored_frameworks
      add_vendored_libraries
      add_resources
      add_other_files
    end

    private

    # Performs platform specific analysis. It requires to download the source
    # at each iteration
    #
    # @note   Xcode warnings are treated as notes because the spec maintainer
    #         might not be the author of the library
    # @return [void]
    def build_xcframework!
      xc_args = @archive_paths.flat_map do |path|
        headers_dir = path.dirname.join(pod_name).join('Headers')
        args = %W[-archive #{path}]
        args + if build_as_framework?
                 %W[-framework #{product_name}]
               else
                 h_a = %W[-headers #{headers_dir}] if headers_dir.exist? && headers_dir.children.count.nonzero?
                 %W[-library #{product_name}] + (h_a || [])
               end
      end
      XcodeBuild.create_xcframework(xc_args, xcframework_product_path)
    end

    # Removes the source files of the Pods to the Pods project.
    #
    # @note   The source files are grouped by Pod and in turn by subspec
    #         (recursively).
    #
    # @return [void]
    #
    def remove_source_files_references
      Pod::UI.message '- Removing source files' do
        extensions = Pod::Sandbox::FileAccessor::SOURCE_FILE_EXTENSIONS
        source_files = file_accessors.flat_map { |file_accessor| file_accessor.send(:source_files) }
        source_files.each do |f|
          next unless extensions.include?(f.extname)

          relative_path = f.relative_path_from(pod_dir)
          full_source_path = @product_path.join(relative_path)
          FileUtils.rm_rf(full_source_path)
        end
      end
    end

    # Adds the bundled frameworks to the Pods project
    #
    # @return [void]
    #
    def add_vendored_frameworks
      Pod::UI.message '- Adding frameworks' do
        add_file_accessors_paths_to_products_group(:vendored_frameworks)
      end
    end

    # Adds the bundled libraries to the Pods project
    #
    # @return [void]
    #
    def add_vendored_libraries
      Pod::UI.message '- Adding libraries' do
        add_file_accessors_paths_to_products_group(:vendored_libraries)
      end
    end

    # Adds the resources of the Pods to the Pods project.
    #
    # @note   The source files are grouped by Pod and in turn by subspec
    #         (recursively) in the resources group.
    #
    # @return [void]
    #
    def add_resources
      Pod::UI.message '- Adding resources' do
        add_file_accessors_paths_to_products_group(:resources)
        add_file_accessors_paths_to_products_group(:resource_bundle_files)
      end
    end

    def add_other_files
      Pod::UI.message '- Adding other files' do
        add_file_accessors_paths_to_products_group(:license)
        add_file_accessors_paths_to_products_group(:readme)
      end
    end

    def add_file_accessors_paths_to_products_group(file_accessor_key)
      fs = file_accessors.flat_map { |file_accessor| file_accessor.send(file_accessor_key) }
      fs.each do |f|
        relative_path = f.relative_path_from(pod_dir)
        full_source_path = product_path.join(relative_path.parent)
        FileUtils.mkdir_p(full_source_path) unless full_source_path.exist?
        FileUtils.cp_r(%W[#{f}], full_source_path)
      end
    end
  end
end