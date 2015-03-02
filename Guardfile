logger level: :debug
interactor :off

ignore /bin/, /public/

guard :bundler do
  watch('Gemfile')
end

guard :bundler_audit, run_on_start: true do
  watch('Gemfile.lock')
end

guard :minitest do
  watch(%r{^test/(.*)?\_test\.rb$})
  watch(%r|^workers/(.*)\.rb|)           { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^models/(.*)\.rb|)            { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test" }
  watch(%r{^apps/(.*/)?([^/]+)\.rb$})    { |m| "test/acceptance" }
  watch(%r{^views/(.*/)?([^/]+)\.rb$})    { |m| "test/acceptance" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
end
