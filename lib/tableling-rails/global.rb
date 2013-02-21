
module Tableling

  def self.settings
    @settings ||= Settings.new
  end

  def self.global &block
    settings.configure &block
  end
end
