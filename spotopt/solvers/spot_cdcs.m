function [x,y,z,info] = spot_cdcs(A,b,c,K,options)
    if nargin < 5, options = spot_sdp_default_options(); end
    
    info = struct();
    
    if isfield(options.solver_options,'cdcs')
        cdcs_options = options.solver_options.cdcs;
    else
        cdcs_options = cdcsOpts;
    end    
    if isfield(options,'verbose')
        cdcs_options.verbose = options.verbose;
    end
    
    % Remove extra fields from K
    fnames = fieldnames(K);
    keep = cellfun(@(X)ismember(X,{'f','l','q','s'}),fnames);
    K = rmfield(K,fnames(~keep));
    
    start = spot_now();
    [x,y,z,s_info] = cdcs(A.',b,c,K,cdcs_options);
    [info.ctime,info.wtime] = spot_etime(spot_now(),start);
    
    if s_info.problem == 0
        status = spotsolstatus.STATUS_PRIMAL_AND_DUAL_FEASIBLE;
    elseif s_info.problem == 1
        status = spotsolstatus.STATUS_PRIMAL_INFEASIBLE;
    elseif s_info.problem == 2
        status = spotsolstatus.STATUS_DUAL_INFEASIBLE;
    else
        status = spotsolstatus.STATUS_UNSOLVED;
    end

    info.status = status;
    info.solverName = 'cdcs';
    info.solverInfo = s_info;
end
