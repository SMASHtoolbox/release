% UNDER construction
%
%    configure(object,source,'Record',value);
%    configure(object,source,'Pattern',pattern);
% can be combined when it makes sense.

function configure(object,source,varargin)

assert(isscalar(object,...
    'ERROR: sources must be configured one configuration at a time'));

% manage input



setting=struct('Format','','Record','','Pattern','');
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid setting name');
    value=varargin{n+1};
    switch lower(name)
        case 'format'
            assert(ischar(value),...
                'ERROR: file format must be a character array');
            setting.Format=value;
        case 'record'
            setting.Record=value;
        case 'pattern'
            assert(ischar(value),...
                'ERROR: pattern must be a character array');
            setting.Pattern=value;
        otherwise
            error('ERROR: invalid setting name');
    end
end

assert(~isempty(setting.Format),'ERROR: source format must be specified');

end