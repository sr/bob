require File.dirname(__FILE__) + "/../helper"

require "sequel"

class QueuedBobTest < Test::Unit::TestCase
  def database
    @database ||= begin
      db = Sequel.sqlite
      db.create_table :builds do
        primary_key :id
        String :kind
        String :uri
        String :branch
        String :command
        String :commit
      end

      db[:builds]
    end
  end

  def setup
    super

    @repo = GitRepo.new(:test_repo)
    repo.create

    @buildable = GitBuildableStub.new(repo)

    push = Proc.new do |buildable, commit|
      database.insert(:kind => buildable.kind.to_s,
        :uri     => buildable.uri,
        :branch  => buildable.branch,
        :command => buildable.build_script,
        :commit  => commit
      )
    end

    Bob.engine = Bob::BackgroundEngines::Queued.new(push)
  end

  test "with a successful threaded build" do
    repo.add_successful_commit
    commit_id = repo.commits.first[:identifier]

    Bob.build(buildable, commit_id)

    assert buildable.builds.empty?
    assert buildable.metadata.empty?

    assert_equal 1, database.count
    assert_equal "git",     database.first[:kind]
    assert_equal repo.path, database.first[:uri]
    assert_equal "master",  database.first[:branch]
    assert_equal "./test",  database.first[:command]
  end
end
