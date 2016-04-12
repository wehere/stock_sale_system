class LossOrder < ActiveRecord::Base
  LOSS_TYPE = {
      3 => '仓库损耗',
      4 => '销售损耗'
  }
end