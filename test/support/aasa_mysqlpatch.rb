# Rails v6 does this for us automatically
#
ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.prepend(Module.new {
  def create_table(table_name, options = {})
    options[:options] = "ENGINE=InnoDB ROW_FORMAT=DYNAMIC"
    super
  end
}) if defined?(ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter)
