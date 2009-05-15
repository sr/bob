module Bob
  module BackgroundEngines
    # Dummy engine that just runs in the foreground (useful for tests).
    Foreground = lambda { |buildable, commit_id, block| block.call }
  end
end
