# frozen_string_literal: true
require 'cocoapods-project-gen'
podspecs = [File.expand_path('./spec/cocoapods/Resources/Specs/no_local/LCombineExtension.podspec', __dir__)]
output_dir = "#{File.expand_path('../output', __dir__)}"
vs = ProjectGen::Command.run(['gen', '--no-local', "--output-dir=#{output_dir}", "--sources=https://cdn.cocoapods.org/", *podspecs, "--platforms=ios", "--use-static-frameworks", "--build-library-for-distribution"])
binary_source = 'ssh://git@gitlab-ha.immotors.com:1122/v-dongzhaobing/vendored_frameworks.git'
vs.each_pair do |_key, ps|
  ps.products.each do |product|
    product_path = product.product_path
    zip_path = product_path.join("#{product_path.basename}.zip")
    ProjectGen::Utils.zip(product_path, zip_path)
    spec_hash = product.root_spec.to_hash
    # 上传pod到服务器
    ProjectGen::Utils.upload(spec_hash, zip_path)
    # 生成podspec
    podspec_path = ProjectGen::BinSpecWithSource.generate(product, spec_hash)
    # 上传 podspec
    ProjectGen::Utils.push_podspec(podspec_path, spec_hash, binary_source)
  end
end