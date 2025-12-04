from discord import app_commands, Interaction

def register_slash_commands(tree: app_commands.CommandTree):

    @tree.command(name="ping", description="Check bot status")
    async def ping(interaction: Interaction):
        await interaction.response.send_message("🏓 Pong!")

    _ = ping # avoid unused warning

        

    @tree.command(name="addschedule", description="Add a schedule")
    async def addschedule(
        interaction: Interaction,
        datetime: str,
        note: str = "No note"
    ):
        # later: call core/services.py
        await interaction.response.send_message(
            f"🗓️ Schedule added:\n- Time: {datetime}\n- Note: {note}"
        )
        
    _ = addschedule  # avoid unused warning
