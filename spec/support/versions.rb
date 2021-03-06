# frozen_string_literal: true
def build_version(args = {})
  name = args.fetch(:name, "test_gem")
  number = args.fetch(:number, "1.0")
  platform = args.fetch(:platform, nil)
  checksum = args.fetch(:checksum, "sum+#{name}+#{number}")
  info_checksum = args.fetch(:info_checksum, "info+#{name}+#{number}")
  dependencies = args.fetch(:dependencies, nil)
  ruby_version = args.fetch(:ruby_version, nil)
  rubygems_version = args.fetch(:rubygems_version, nil)
  CompactIndex::GemVersion.new(number, platform, checksum, info_checksum, dependencies, ruby_version, rubygems_version)
end
