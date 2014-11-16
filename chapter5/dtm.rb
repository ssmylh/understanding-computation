# -*- encoding: utf-8 -*-

require_relative 'tm.rb'

class DTMRulebook < Struct.new(:rules)
  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end
  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end
end

class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end
  def step
    self.current_configuration = rulebook.next_configuration(current_configuration)
  end
  def run
    step until accepting?
  end
end

rulebook = DTMRulebook.new([
  TMRule.new(1, '0', 2, '1', :right),
  TMRule.new(1, '1', 1, '0', :left),
  TMRule.new(1, '_', 2, '1', :right),
  TMRule.new(2, '0', 2, '0', :right),
  TMRule.new(2, '1', 2, '1', :right),
  TMRule.new(2, '_', 3, '_', :left)
])

tape = Tape.new(['1', '0', '1'], '1', [], '_')
configuration = TMConfiguration.new(1, tape)
p configuration
configuration = rulebook.next_configuration(configuration)
p configuration
configuration = rulebook.next_configuration(configuration)
p configuration
configuration = rulebook.next_configuration(configuration)
p configuration

dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
dtm.run
p dtm.current_configuration