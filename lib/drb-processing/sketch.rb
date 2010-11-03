#!/usr/bin/env ruby

address, port = ARGV

ROOT = File.expand_path(File.dirname(__FILE__) + "/../..")
LIB = File.join(ROOT, "lib")
$:.unshift(LIB) unless $:.include?(LIB)
$:.unshift("#{ROOT}/vendor/drbfire/lib")

require "drb-processing/client"

java_import 'java.awt.event.WindowEvent'
java_import 'java.awt.event.KeyEvent'
require 'logger'

class Sketch < Processing::App
  def initialize(options = {})
    @address = options[:address]
    @port = options[:port] || 9000
    super
  end
  def setup
    $client = DRbProcessing::Client.new(self)
    $client.logger = Logger.new(STDOUT)
    $client.connect @address, @port
  end
  def draw
  end
  def close
    $client.disconnect
    super
  end
  def determine_how_to_display(*args)
    super
    if @frame
      @frame.add_window_listener do |event|
        if event.iD == WindowEvent::WINDOW_CLOSING #iD avoids warning meant for Object#id
          close
        end
      end
      @frame.add_key_listener do |event|
        if event.key_code == KeyEvent::VK_ESCAPE
          close
        end
      end
    end
  end
  def handleKeyEvent(event) #Not snake_case, we need to override an existing Java method!
    if event.key_code == KeyEvent::VK_ESCAPE
      close
    end
    super
  end
end

sketch = Sketch.new(:address => address, :port => port, :width => 1280, :height => 1000, :title => '', :full_screen => false)
