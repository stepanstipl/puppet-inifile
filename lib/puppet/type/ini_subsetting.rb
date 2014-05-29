require 'digest/md5'

Puppet::Type.newtype(:ini_subsetting) do

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:section) do
    desc 'The name of the section in the ini file in which the setting should be defined.'
  end

  newparam(:setting) do
    desc 'The name of the setting to be defined.'
  end

  newparam(:subsetting) do
    desc 'The name of the subsetting to be defined.'
  end

  newparam(:subsetting_separator) do
    desc 'The separator string between subsettings. Defaults to " "'
    defaultto(" ")
  end

  newparam(:path) do
    desc 'The ini file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  newparam(:key_val_separator) do
    desc 'The separator string to use between each setting name and value. ' +
        'Defaults to " = ", but you could use this to override e.g. whether ' +
        'or not the separator should include whitespace.'
    defaultto(" = ")

    validate do |value|
      unless value.scan('=').size == 1
        raise Puppet::Error, ":key_val_separator must contain exactly one = character."
      end
    end
  end

  newparam(:quote_char) do
    desc 'The character used to quote the entire value of the setting. ' +
        %q{Valid values are '', '"' and "'". Defaults to ''.}
    defaultto('')

    validate do |value|
      unless value =~ /^["']?$/
        raise Puppet::Error, %q{:quote_char valid values are '', '"' and "'"}
      end
    end
  end

  newparam(:keep_secret) do
    desc 'Whether puppet should treat this as sensitive information ' +
        'and not output value in the logs.'
    defaultto :false
    newvalues(:true, :md5, :false)
  end

  newproperty(:value) do
    desc 'The value of the subsetting to be defined.'

    def should_to_s(newvalue)
      if (@resource[:keep_secret] == :true) then
        return '[redacted sensitive information]'
      elsif (@resource[:keep_secret] == :md5) then
        return '{md5}' + Digest::MD5.hexdigest(newvalue.to_s)
      else
        return newvalue
      end
    end

    def is_to_s(value)
        should_to_s(value)
    end

  end

end
