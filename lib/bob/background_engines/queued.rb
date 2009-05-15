module Bob
  module BackgroundEngines
    class Queued
      def initialize(push)
        @push = push
      end

      def call(buildable, commit_id, &job)
        @push.call(buildable, commit_id, &job)
      end
    end
  end
end
