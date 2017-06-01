require_relative '../helpers/run_command'

class GitRepository
  include RunCommand

  def initialize(uri, path)
    @uri = uri
    @path = path
  end

  def clone
    run_command "git clone #{@uri} #{@path}"
  end

  def checkout(ref)
    within_repo do
      begin
        run_command "git checkout --force '#{ref}' --"
      rescue StandardError => e
        if e.message =~ /fatal: invalid reference/
          # old git versions get distracted by '--' at the end and this shortcut
          # does not work anymore
          run_command "git checkout --force -b '#{ref}' --track 'origin/#{ref}'"
        else
          raise e
        end
      end
    end
  end

  def within_repo
    Dir.chdir @path do
      yield
    end
  end

  def submodule_init_and_update
    within_repo do
      run_command 'git submodule update --init'
    end
  end

  def add(path)
    within_repo do
      run_command "git add #{path}"
    end
  end

  def commit(message)
    within_repo do
      run_command "git commit -m '#{message}'"
    end
  end

  def push(push_tags = false)
    command = 'git push'
    command << ' --tags' if push_tags
    within_repo do
      run_command command
    end
  end

  def branch
    within_repo do
      run_command 'git rev-parse --abbrev-ref HEAD'
    end
  end
end
