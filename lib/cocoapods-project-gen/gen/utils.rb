require 'fileutils'
require 'cocoapods'

module ProjectGen
  module Utils
    # @return [Bool]
    #
    def self.absolute?(path)
      Pathname(path).absolute? || path.to_s.start_with?('~')
    end

    def self.remove_target_scope_suffix(label, scope_suffix)
      if scope_suffix.nil? || scope_suffix[0] == '.'
        label.delete_suffix(scope_suffix || '')
      else
        label.delete_suffix("-#{scope_suffix}")
      end
    end

    def self.zip(product_path, zip_path)
      # product_name = Pathname.new(product_path).basename
      zip_product_name = Pathname.new(zip_path).basename
      FileUtils.rm_rf(zip_path)
      FileUtils.mkdir_p(zip_path.dirname)
      Dir.chdir(product_path) do
        _ = `zip -r #{zip_product_name.to_s} "./"`
        # $stdout.puts("path: #{zip_path}".green)
      end
    end

    def self.upload(spec_hash, zip_path)
      $stdout.puts("上传二进制文件: #{zip_path}".green)
      name = spec_hash['name']
      version = spec_hash['version']
      ip_addr = "http://127.0.0.1:8081/frameworks"
      cmds = ['curl']
      cmds << "-s -o /dev/null"
      cmds << ip_addr
      cmds << "-F name=#{name}"
      cmds << "-F version=#{version}"
      cmds << "-F file=@#{zip_path}"
      cmds_to_s = cmds.join(" ")
      _ = `#{cmds_to_s}`
    end

    def self.push_podspec(podspec_path, spec_hash, source_url)
      source = Pod::Config.instance.sources_manager.all.select {  |s| s.url == source_url }.first
      return unless source
      root_path = source.repo
      name = spec_hash['name']
      version = spec_hash['version']
      copy_path = root_path.join(name).join("#{version}-binary")
      Dir.chdir(root_path)
      system("git reset --hard")
      system("git pull origin master")
      if copy_path.exist?
        FileUtils.rm_f(copy_path)
        FileUtils.mkdir_p(copy_path)
      else
        FileUtils.mkdir_p(copy_path)
      end
      FileUtils.cp_r(podspec_path, copy_path)
      before_path = Dir.pwd
      system("git status")
      system("git add .")
      system("git commit -m 'Update #{version}'")
      system("git push origin master")
      Dir.chdir(before_path)
    end


  end
end
