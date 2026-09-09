# Setting Up Atlassian MCP for Claude Code on Remote Dev VMs
When running Claude Code on a remote VM (via SSH), the Atlassian MCP OAuth flow requires a local SSH tunnel because:

- The OAuth callback redirects to `localhost:<port>` in your browser (on your laptop)
- The MCP server listening for that callback is on the remote VM

## Steps -- NOTE: this is deprecated

1. Start Claude Code on your remote VM and trigger the Atlassian MCP authentication (e.g. ask Claude to use an Atlassian tool, or run `mcp__atlassian__authenticate`).

2. Note the callback port from the auth URL. It will look like:

```
redirect_uri=http://localhost:61123/callback
```

In this example, the port is `61123`. **Do not open the URL yet.**

3. Open a new terminal on your laptop and create an SSH tunnel that forwards the callback port from your laptop to the VM:

```
ssh -L <port>:localhost:<port> <your-vm-ssh-host>
```

For example:

```
ssh -L 61123:localhost:61123 vagrant@192.168.100.10
```

If your SSH config uses a ProxyJump / bastion host, you can either use your configured host alias or specify it explicitly:

```
ssh -J user@vagrant -L 61123:localhost:61123 user@vm-hostname
```

4. Open the auth URL in your browser immediately — the callback listener on the VM times out quickly. Complete the Atlassian authorization flow (select your site, grant permissions).

5. Verify the connection by asking Claude to use an Atlassian tool (e.g. search Jira issues). The tools should now be available.

## Troubleshooting
- **"Connection refused" in browser after auth:** The callback listener timed out. Go back to step 1 and repeat — be quick between setting up the tunnel and completing the OAuth flow.
- **Tunnel won't bind the port:** Make sure nothing else is using that port on your laptop. Check with lsof -i :<port> (macOS/Linux).
- **Auth code expired:** OAuth codes are short-lived (~5 minutes). If you take too long between steps, start over from step 1.
- **Credentials expire later:** Access tokens expire periodically. When they do, repeat this process. Refresh tokens may extend the session automatically, but if tools stop working, re-authenticate.

## Tips
- Have your SSH tunnel command ready to paste before triggering auth, so you can set it up quickly.
- If your team frequently uses the same VM, consider adding a LocalForward to your SSH config for common port ranges, though the MCP server picks random ports each time.
