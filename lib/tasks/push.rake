namespace :push do
  desc "提交代码"
  task :push do
    message_file = "#{Rails.root}/public/temp/message.txt"
    message = `cat #{message_file}`
    branch = `git branch`
    b = branch.match /\*\s([_a-zA-Z\d]+)\n/
    current_branch = b[1]
    `git add . && git commit -am #{message} && git push origin #{current_branch}`
    `git push origin #{current_branch}`
  end
end
