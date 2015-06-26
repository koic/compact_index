require 'sequel'
require 'spec_helper'
require 'compact_index/gem_info'
require 'support/gem_builder'

describe CompactIndex::GemInfo do
  let(:db)       { $db }
  let(:builder)  { GemBuilder.new(db) }
  let(:gem_info) { CompactIndex::GemInfo.new(db) }

  describe "#deps_for" do
    context "no gems" do
      it "should find the deps" do
        expect(gem_info.deps_for(['rack'])).to eq([])
      end
    end

    context "no dependencies" do
      before do
        rack_id = builder.create_rubygem('rack')
        builder.create_version(rack_id, 'rack')
      end

      it "should return rack" do
        result = [{
          name:         'rack',
          number:       '1.0.0',
          platform:     'ruby',
          rubygems_version: nil,
          required_ruby_version: nil,
          checksum: nil,
          dependencies: []
        }]

        expect(gem_info.deps_for(['rack'])).to eq(result)
      end
    end

    context "has one dependency" do
      before do
        rack_id         = builder.create_rubygem('rack')
        rack_version_id = builder.create_version(rack_id, 'rack')

        foo_id = builder.create_rubygem('foo')
        builder.create_version(foo_id, 'foo')
        builder.create_dependency(foo_id, rack_version_id, "= 1.0.0")
      end

      it "should return foo as a dep of rack" do
        result = [{
          name:         'rack',
          number:       '1.0.0',
          platform:     'ruby',
          rubygems_version: nil,
          required_ruby_version: nil,
          checksum: nil,
          dependencies: [['foo', '= 1.0.0']]
        }]

        expect(gem_info.deps_for(['rack'])).to eq(result)
      end
    end

    context "all gems" do
      before do
        rack_id = builder.create_rubygem('rack')
        builder.create_version(rack_id, 'rack')
      end

      it "should return rack" do
        result = [{
          name:         'rack',
          number:       '1.0.0',
          platform:     'ruby',
          rubygems_version: nil,
          required_ruby_version: nil,
          checksum: nil,
          dependencies: []
        }]

        expect(gem_info.deps_for).to eq(result)
      end
    end

    context "filters on indexed" do
      before do
        rack_id                     = builder.create_rubygem('rack')
        rack_version_id             = builder.create_version(rack_id, 'rack', '1.1.0')
        non_indexed_rack_version_id = builder.create_version(rack_id, 'rack', '1.0.0', 'ruby', { indexed: false })

        foo_id = builder.create_rubygem('foo')
        builder.create_version(foo_id, 'foo')
        builder.create_dependency(foo_id, rack_version_id, "= 1.0.0")
        builder.create_dependency(foo_id, non_indexed_rack_version_id, "= 1.0.0")
      end

      it "should not return nonindexed gems" do
        result = [{
          name:         'rack',
          number:       '1.1.0',
          platform:     'ruby',
          rubygems_version: nil,
          required_ruby_version: nil,
          checksum: nil,
          dependencies: [['foo', '= 1.0.0']]
        }]

        expect(gem_info.deps_for(['rack'])).to eq(result)
      end
    end
  end

  describe "#names" do
    before do
      builder.create_rubygem("a")
      builder.create_rubygem("c")
      builder.create_rubygem("b")
      builder.create_rubygem("d")
    end

    it "should return the list back in order" do
      expect(gem_info.names).to eq(%w(a b c d))
    end
  end

  describe "#versions" do
    before do
      a = builder.create_rubygem("a")
      b = builder.create_rubygem("b")
      c = builder.create_rubygem("c")
      d = builder.create_rubygem("d-d")
      builder.create_version(a, "a")
      builder.create_version(a, "a", "1.0.1")
      builder.create_version(b, "b")
      builder.create_version(b, "b", "1.0.1", "ruby", { indexed: false })
      builder.create_version(c, "c", "1.0.0", "java")
      builder.create_version(d, "d-d", "1.0.0")
      builder.create_version(d, "d-d", "1.0.0", "java")
    end

    it "should return a hash of gems and versions" do
      result = {
        "a" => ["1.0.0", "1.0.1"],
        "b" => ["1.0.0"],
        "c" => ["1.0.0-java"],
        "d-d" => ["1.0.0", "1.0.0-java"],
      }
      expect(gem_info.versions).to eq(result)
    end
  end
end