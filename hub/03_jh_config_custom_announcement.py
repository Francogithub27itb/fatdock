## announcements

c.JupyterHub.services.append({
            'name': 'announcement',
            'url': 'http://hub:8888',        
            'command': [sys.executable, "-m", "jupyterhub_announcement"]
})



