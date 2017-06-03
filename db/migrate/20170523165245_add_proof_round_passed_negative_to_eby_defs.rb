class AddProofRoundPassedNegativeToEbyDefs < ActiveRecord::Migration
  def change
    add_column :eby_defs, :proof_round_passed_negative, :integer
    print 'populating proof_round_passed_negative field... '
    EbyDef.all.each do |d|
      d.proof_round_passed_negative = -(d.proof_round_passed)
      d.save
    end
    puts 'done!'
  end
end
