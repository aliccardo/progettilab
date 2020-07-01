class Ability
  include CanCan::Ability

  def initialize(user)
    # Autorizzazioni

    alias_action :read, :jobs, :attachments, :search, :searched, :logs, :reports, :analisies, :to => :viewer

    # RUOLI:
    #  user.admin? # Amministratore del programma
    #  user.chief? # Resp. area
    #  user.supervisor? # Supervisore (es. Resp. Qualità)

    if user
      can :viewer, :all
      Job.unscoped.each do | job |
        can :download, Report, job_id: job.id
        cannot :manage, JobRole, job_id: job.id
        if job.opened?
          can :destroy, job if user.chief? || user.supervisor?
          if user.admin? || user.chief? || user.supervisor? || user.jobs_as_manager_ids.include?( job.id ) || user.jobs_as_technician_ids.include?( job.id )
            can :create, job => Sample
            can :create, job => Analisy
            can :create, job => AnalisyResult
            can :manage, Attachment, id: job.attachment_ids
            can :manage, Sample, job_id: job.id
            can :manage, Analisy
            can :manage, AnalisyResult
          end
          if user.admin? || user.chief? || user.supervisor? || user.jobs_as_manager_ids.include?( job.id )
            can :update, job
            can :close, Job, id: job.id
            can :manage, Timetable, job_id: job.id
            can :create, Report
            can :destroy, Report, job_id: job.id
          end
        elsif job.closed?
          can :reopen, Job, id: job.id if user.admin? || user.chief? || user.supervisor? || user.jobs_as_manager_ids.include?( job.id )
        end
        cannot [ :destroy ], Job, id: job.reports.pluck(:job_id)
        cannot [ :destroy ], Sample, id: job.report_sample_ids
        cannot [ :update, :destroy ], Analisy, id: job.report_analisy_ids
        cannot [ :update, :destroy ], AnalisyResult, id: job.report_result_ids

        can :update_chief, JobRole, job_id: job.id if user.admin?
        can :update_managers, JobRole, job_id: job.id if user.admin? || user.chief? || user.supervisor?
        can :update_technicians, JobRole, job_id: job.id if user.admin? || user.chief? || user.supervisor? || user.jobs_as_manager_ids.include?( job.id )
      end
      can [:print, :printed], Job
      can :manage, [ User, AnalisyType, Nuclide, Unit, MatrixType, Instruction ] if user.admin? || user.chief?
      can :create, Job if user.chief? || user.supervisor?
    end
  end
end
