module SpreeFlutterwave
  VERSION = '1.0.1'.freeze

  module_function

  # Returns the version of the currently loaded SpreeFlutterwave as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
