# Not perfect. We want to avoid bundling native gems
# required in each adapter, like mysql2.
#
ORIG_GEM_METHOD = method(:gem)
kernel = (class << ::Kernel; self; end)
[kernel, ::Kernel].each do |k|
  k.send :remove_method, :gem
  k.send :define_method, :gem do |dep, *reqs|
    # TODO: [PG] Add 'postgresql' here.
    unless ['mysql2'].include?(dep)
      ORIG_GEM_METHOD.call(dep, *reqs)
    end
  end
  k.send :public, :gem
end
