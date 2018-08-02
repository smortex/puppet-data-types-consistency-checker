#!/usr/bin/env ruby

require './epp_parser.tab'
require './pp_parser.tab'
require './template_parser.tab'

ARGV.each do |path|
  Dir.chdir path

  manifests = Dir['manifests/**/*.pp']
  epp_templates = Dir['templates/**/*.epp']

  @variables = {}

  manifests.each do |pp|
    parser = PpParser.new

    parser.parse(File.read(pp))

    parser.variables.each do |name, type|
      @variables[name] ||= {}
      @variables[name][pp] = type
    end
  end

  epp_templates.each do |epp|
    parser = TemplateParser.new

    parser.parse(File.read(epp))

    parser.variables.each do |name, type|
      @variables[name] ||= {}
      @variables[name][epp] = type
    end
  end

  @variables.each do |name, instances|
    next if instances.values.uniq.count == 1
    puts "Inconsistencies found for #{name}:"
    instances.each do |filename, type|
      puts format('  - %<type>-30s %<filename>s', type: type, filename: filename)
    end
    puts
  end
end
