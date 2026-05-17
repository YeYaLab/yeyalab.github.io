# frozen_string_literal: true

# Compatibility runner for Ruby 4 on Windows.
# Jekyll relies on Dir[glob] while booting; in this environment it can return
# empty for gem paths, so the CLI commands and filters are not loaded.

require "rubygems"
require "bundler/setup"
require "liquid"

liquid_lib = File.join(Gem::Specification.find_by_name("liquid").gem_dir, "lib")
Dir.children(File.join(liquid_lib, "liquid", "tags")).sort.each do |entry|
  path = File.join(liquid_lib, "liquid", "tags", entry)
  require path if File.file?(path) && File.extname(path) == ".rb"
end

require "jekyll/filters/url_filters"
require "jekyll/filters/grouping_filters"
require "jekyll/filters/date_filters"
require "jekyll"

jekyll_lib = File.join(Gem::Specification.find_by_name("jekyll").gem_dir, "lib")

def require_jekyll_files(base, relative_dir)
  dir = File.join(base, relative_dir)
  return unless Dir.exist?(dir)

  Dir.children(dir).sort.each do |entry|
    path = File.join(dir, entry)
    require path if File.file?(path) && File.extname(path) == ".rb"
  end
end

[
  "jekyll/commands",
  "jekyll/converters",
  "jekyll/converters/markdown",
  "jekyll/drops",
  "jekyll/generators",
  "jekyll/tags"
].each do |relative_dir|
  require_jekyll_files(jekyll_lib, relative_dir)
end

load Gem.bin_path("jekyll", "jekyll")
