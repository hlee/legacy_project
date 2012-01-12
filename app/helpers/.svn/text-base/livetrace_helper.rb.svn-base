module LivetraceHelper
    def show_analyzer(site_name)
        site_id=Site.find_by_name(site_name)
        switch_id=SwitchPort.find_by_site_id(site_id).switch_id
        Switch.find_by_id(switch_id).id
    end
    def show_port(site_name)
        SwitchPort.find_by_site_id(Site.find_by_name(site_name)).port_nbr
    end
end
