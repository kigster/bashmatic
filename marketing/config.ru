require 'rack'
require 'stringio'

class ServerSideIncludes
  attr_reader :path, :output_file, :contents

  def initialize(path)
    @path = path
    @output_file = File.join('tmp/', File.basename(path))
  end

  def contents
    return File.open(path) unless path.end_with?('.html')
    
    output = File.read(path)
    while output.include?('<!--#include virtual="')
      output.gsub!(/<!--#include virtual="([^"]+)" -->/) do
        included_file = ::Regexp.last_match(1)
        included_path = File.join(File.dirname(path), included_file)
        File.read(included_path) if File.exist?(included_path)
      end
    end
    File.open(output_file, 'w') do |f|
      f.write(output)
    end
    File.open(output_file, File::RDONLY)
  end
end

app = Rack::Builder.new do
  use Rack::Static,
      root: './public',
      urls: ['/index.html', '/readme.html', '/readme.pdf', '/assets/css', '/assets/js', '/assets/fonts', '/assets/img'],
      index: 'index.html',
      header_rules: [
        ['/readme.pdf',  { 'Content-Type' => 'application/pdf' }],
        ['/assets/js',  { 'Content-Type' => 'text/javascript' }],
        ['/assets/css', { 'Content-Type' => 'text/css' }],
        ['/assets/img', { 'Content-Type' => 'image/png' }],
        ['/assets/fonts/FantasqueSansMono-Regular.ttf', { 'Content-Type' => 'font/ttf' }],
        ['/assets/fonts/FantasqueSansMono-Bold.ttf', { 'Content-Type' => 'font/ttf' }],
        ['/assets/fonts/FantasqueSansMono-Italic.ttf', { 'Content-Type' => 'font/ttf' }],
        ['/assets/fonts/FantasqueSansMono-BoldItalic.ttf', { 'Content-Type' => 'font/ttf' }],
        ['/assets/css/output-colors.css', { 'Content-Type' => 'text/css' }],
        ['/assets/css/styles.css', { 'Content-Type' => 'text/css' }]
      ]

  run do |env|
    [
      200,
      { "Content-Type": 'text/html' },
      File.open(ServerSideIncludes.new("public/#{env['PATH_INFO'] == '/' ? 'index.html' : env['PATH_INFO']}").contents)
    ]
  end
end

run app
