# The `citations` fixture exceeds our `max_allowed_packet` size
# and will raise a `Fixtures set is too large` error. Also, since
# we do not support batch operations, 65K inserts is just too slow.
#
if defined?(FIXTURES_ROOT)
  citations_file = File.join FIXTURES_ROOT, 'citations.yml'
  citations_data = File.read(citations_file).sub '65536.times', '1500.times'
  File.open(citations_file, 'w') { |f| f.write(citations_data) }
end
