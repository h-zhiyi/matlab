% pop_importctf() - imports CTF DataSet (pop out window if no arguments).
%
% Usage:
%   >> EEG = pop_importctf;             % a window pops up
%   >> EEG = pop_importctf( dsfolder );
%
% Inputs:
%   datafile       - A datafile within a DS folder containing BrainStorm datafiles
% 
% Outputs:
%   EEG            - EEGLAB data structure
%
% Author: Karim N'Diaye, CNRS-UPR640, 01 Jan 2004
%
% See also: eeglab(), importctf()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2004, CNRS - UPR640, N'Diaye Karim,
% karim.ndiaye@chups.jussieu.Fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_importctf.m,v $
% Revision 0.1  2004/01/01 
% First alpha version for EEGLAB release 4.301
%

function [EEG, command] = pop_importctf(datafile); 
    
EEG = [];
command = '';
if nargin < 1 
	% ask user
    try
        cd('D:\ndiaye\data\studies\div\Savg\avgdata\div-d-avTone1.ds');
    catch
    end
	[filename, filepath] = uigetfile('*.hc', 'Choose a DS folder -- pop_importctf()');
    drawnow;
	if filename == 0 return; end;    
    [dsfolder]=fileparts(fullfile(filepath, filename)) ;
end;

% load data
% ---------
EEG = eeg_emptyset;
[data channel ] = importctf(dsfolder);

EEG.filename        = data.RunTitle
EEG.filepath        = dsfolder;
EEG.setname 		= ['CTF data:' data.RunTitle ];
EEG.nbchan          = length(channel);
EEG.srate           = 1/mean(diff(data.Time));
EEG.trials          = length(data.F);
EEG.pnts            = length(data.Time);
EEG.times           = data(1).Time;
EEG.xmin            = EEG.times(1); % huh??
EEG.xmax            = EEG.times(end); % huh??
%Caution! CELL2MAT is overloaded in EEGLAB environment
fprintf('Importing data...(may take a while)')
EEG.data=zeros([EEG.nbchan EEG.pnts EEG.trials]);
for i=1:EEG.trials
    EEG.data(:,:,i)=data.F{i};
end
% EEG.comments = study.Session;
EEG.comments = sprintf('Imported from CTF dataset: %s', dsfolder);
EEG.ref = ['common'];

fprintf('Importing channel location information')
for i=1:length(channel)    
    eloc(i).X=channel(i).Loc(1);
    eloc(i).Y=channel(i).Loc(2);
    eloc(i).Z=channel(i).Loc(3);
    eloc(i).labels=channel(i).Name;
end
EEG.chanlocs=convertlocs(eloc, 'cart2all')

EEG = eeg_checkset(EEG);
command = sprintf('EEG = pop_importctf(''%s'');', dsfolder); 

return;



% importing the events
% --------------------
if ~isempty(Eventdata)
    orinbchans = EEG.nbchan;
    for index = size(Eventdata,1):-1:1
        EEG = pop_chanevent( EEG, orinbchans-size(Eventdata,1)+index, 'edge', 'leading', ...
                             'delevent', 'off', 'typename', Head.eventcode(index,:), ...
                             'nbtype', 1, 'delchan', 'on');
    end;
end;
return

%EEG = 
%
%             setname: 'Continuous EEG Data epochs'
%            filename: 'eeg_demo_squareepochs.set'
%            filepath: ''
%                pnts: 384
%              nbchan: 32
%              trials: 80
%               srate: 128
%                xmin: -1
%                xmax: 1.9922
%                data: [32x384x80 single]
%             icawinv: []
%           icasphere: []
%          icaweights: []
%              icaact: []
%               event: [1x157 struct]
%               epoch: [1x80 struct]
%            chanlocs: [1x32 struct]
%            comments: [9x769 char]
%              averef: 'no'
%                  rt: []
%    eventdescription: {[2x29 char]  [2x63 char]  [2x36 char]  ''}
%    epochdescription: {}
%            specdata: []
%          specicaact: []
%              reject: [1x1 struct]
%               stats: [1x1 struct]
%          splinefile: []
%                 ref: 'averef'
%             history: [11x108 char]
%               times: [1x384 double]

% EEG.event
% 1x157 struct array with fields:
%    type: 'square' or 'rt'
%    position: [1] or [2]
%    latency: in ms from the beginning of the continuous recording
%    epoch: the epoch in which the event falls (indexed from 1)

%  EEG.epoch
% 1x80 struct array with fields:
%    event: the index of the events that fall in that one epoch
%    eventlatency: the latency of each event
%    eventposition: the position of each event
%    eventtype: the type of each event


