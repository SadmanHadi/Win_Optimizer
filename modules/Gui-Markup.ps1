<#
================================================================================
  PumpkiN's Modular Suite: Cyberpunk Dark WPF (XAML) UI Markup
================================================================================
#>

$Global:xamlContent = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PumpkiN Ultimate Gaming Optimizer &amp; Software Suite"
    Height="840" Width="1240"
    MinHeight="700" MinWidth="1000"
    WindowStartupLocation="CenterScreen"
    Background="#0F141C"
    Foreground="#F1F5F9"
    FontFamily="Segoe UI">

    <Window.Resources>
        <!-- Dark Cyberpunk Styles -->
        <SolidColorBrush x:Key="BgDark" Color="#0F141C"/>
        <SolidColorBrush x:Key="BgCard" Color="#161E2B"/>
        <SolidColorBrush x:Key="BgCardHover" Color="#1E293B"/>
        <SolidColorBrush x:Key="BorderDark" Color="#26354A"/>
        <SolidColorBrush x:Key="AccentCyan" Color="#00D2FF"/>
        <SolidColorBrush x:Key="AccentOrange" Color="#FF7700"/>
        <SolidColorBrush x:Key="AccentGreen" Color="#00FF88"/>
        <SolidColorBrush x:Key="TextDim" Color="#94A3B8"/>
        <SolidColorBrush x:Key="ConsoleBg" Color="#0A0E14"/>

        <!-- Primary Cyan Button Style -->
        <Style x:Key="CyanButton" TargetType="Button">
            <Setter Property="Background" Value="#00D2FF"/>
            <Setter Property="Foreground" Value="#0A0E14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#38BDF8"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#0284C7"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Accent Orange Button Style -->
        <Style x:Key="OrangeButton" TargetType="Button">
            <Setter Property="Background" Value="#FF7700"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FB923C"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#EA580C"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Dark Outlined Button Style -->
        <Style x:Key="DarkOutlineButton" TargetType="Button">
            <Setter Property="Background" Value="#161E2B"/>
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="BorderBrush" Value="#26354A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="12,7"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1E293B"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Category Chip Style (ToggleButton or Button) -->
        <Style x:Key="CategoryChip" TargetType="Button">
            <Setter Property="Background" Value="#161E2B"/>
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="BorderBrush" Value="#26354A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Margin" Value="0,0,8,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="12" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- CheckBox Dark Style -->
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Margin" Value="0,4,0,4"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <!-- TabItem Cyberpunk Style -->
        <Style TargetType="TabItem">
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="20,12"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="tabBorder" Background="Transparent" BorderThickness="0,0,0,2" BorderBrush="Transparent" Margin="0,0,10,0" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" ContentSource="Header"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="tabBorder" Property="BorderBrush" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Foreground" Value="#F1F5F9"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="210"/>
        </Grid.RowDefinitions>

        <!-- TOP BAR: Cyberpunk Header -->
        <Border Grid.Row="0" Background="#121822" BorderBrush="#26354A" BorderThickness="0,0,0,1" Padding="20,14">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="âš¡" FontSize="26" Foreground="#FF7700" Margin="0,0,12,0" VerticalAlignment="Center"/>
                    <StackPanel>
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="PUMPKIN" FontSize="20" FontWeight="Bold" Foreground="#00D2FF" VerticalAlignment="Center"/>
                            <TextBlock Text=" ULTIMATE OPTIMIZER" FontSize="20" FontWeight="Bold" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                            <Border Background="#FF7700" CornerRadius="3" Padding="6,2" Margin="10,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="v2.5.0" FontSize="11" FontWeight="Bold" Foreground="#0F141C"/>
                            </Border>
                        </StackPanel>
                        <TextBlock Text="Ultra Low-Latency Windows Kernel Engine &amp; 10-Category WinGet Software Suite" FontSize="12" Foreground="#94A3B8" Margin="0,2,0,0"/>
                    </StackPanel>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <Button Name="BtnRestorePointTop" Content="ðŸ›¡ï¸ Create Restore Point" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                    <Button Name="BtnMasActivateTop" Content="ðŸ”‘ MAS Activation" Style="{StaticResource DarkOutlineButton}"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN TAB CONTROL -->
        <TabControl Grid.Row="1" Background="Transparent" BorderThickness="0" Margin="14,10,14,0">

            <!-- TAB 1: SOFTWARE DOWNLOADER -->
            <TabItem Header="ðŸ“¦ Software Downloader">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="260"/>
                    </Grid.ColumnDefinitions>

                    <!-- TOP FILTER & CATEGORY CHIPS -->
                    <Border Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,0,0,10">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <!-- Search Input -->
                            <Grid Grid.Row="0" Margin="0,0,0,10">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBox Name="TxtSearch" Height="34" Background="#0F141C" Foreground="#FFFFFF" BorderBrush="#26354A" BorderThickness="1" Padding="10,6" FontSize="13" VerticalContentAlignment="Center"/>
                                <TextBlock IsHitTestVisible="False" Text="ðŸ” Search 100+ applications (e.g. Brave, Discord, Steam, VS Code)..." VerticalAlignment="Center" Margin="12,0,0,0" Foreground="#64748B" FontSize="13">
                                    <TextBlock.Style>
                                        <Style TargetType="TextBlock">
                                            <Setter Property="Visibility" Value="Collapsed"/>
                                            <Style.Triggers>
                                                <DataTrigger Binding="{Binding Text, ElementName=TxtSearch}" Value="">
                                                    <Setter Property="Visibility" Value="Visible"/>
                                                </DataTrigger>
                                            </Style.Triggers>
                                        </Style>
                                    </TextBlock.Style>
                                </TextBlock>
                                <Button Name="BtnClearSearch" Grid.Column="1" Content="Clear" Style="{StaticResource DarkOutlineButton}" Margin="10,0,0,0"/>
                            </Grid>

                            <!-- Horizontal Scrollable Category Chips -->
                            <ScrollViewer Grid.Row="1" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled">
                                <StackPanel Name="StackCategoryChips" Orientation="Horizontal">
                                    <Button Name="ChipCatAll" Content="All Apps (100+)" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatBrowsers" Content="Browsers" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatComms" Content="Communications" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatDev" Content="Development" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatDoc" Content="Document" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatGames" Content="Games" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatMs" Content="Microsoft Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatMedia" Content="Multimedia Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatPro" Content="Pro Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatSelf" Content="Selfhosted Tools" Style="{StaticResource CategoryChip}"/>
                                    <Button Name="ChipCatUtil" Content="Utilities" Style="{StaticResource CategoryChip}"/>
                                </StackPanel>
                            </ScrollViewer>
                        </Grid>
                    </Border>

                    <!-- APP CARDS GRID (SCROLLABLE WRAPPANEL) -->
                    <Border Grid.Row="1" Grid.Column="0" Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="8" Margin="0,0,10,0">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <WrapPanel Name="WrapPackages" Margin="4"/>
                        </ScrollViewer>
                    </Border>

                    <!-- ACTION SIDEBAR -->
                    <Border Grid.Row="1" Grid.Column="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Text="ACTIONS" FontSize="12" FontWeight="Bold" Foreground="#94A3B8" Margin="0,0,0,10"/>
                                <Button Name="BtnInstallSelected" Content="âš¡ Install Selected" Style="{StaticResource CyanButton}" Margin="0,0,0,10"/>
                                <Button Name="BtnUninstallSelected" Content="ðŸ—‘ï¸ Uninstall Selected" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,10"/>
                                <Button Name="BtnUpgradeAll" Content="ðŸ”„ Upgrade All (WinGet)" Style="{StaticResource OrangeButton}" Margin="0,0,0,14"/>
                            </StackPanel>

                            <Separator Grid.Row="1" Background="#26354A" Margin="0,0,0,14"/>

                            <StackPanel Grid.Row="2">
                                <TextBlock Text="SELECTION" FontSize="12" FontWeight="Bold" Foreground="#94A3B8" Margin="0,0,0,8"/>
                                <Button Name="BtnSelectAll" Content="Select Visible" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,8"/>
                                <Button Name="BtnClearAll" Content="Clear Selection" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,12"/>
                                <TextBlock Name="TxtSelectedCount" Text="0 apps selected" FontSize="12" Foreground="#00D2FF" FontWeight="SemiBold"/>
                            </StackPanel>

                            <Border Grid.Row="3" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10">
                                <TextBlock Text="ðŸ’¡ WinGet installs directly from official vendor repositories with silent parameters." FontSize="11" Foreground="#64748B" TextWrapping="Wrap"/>
                            </Border>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 2: GAMING TWEAKS -->
            <TabItem Header="ðŸŽ® Gaming Tweaks">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <!-- COLUMN 1: GPU, LATENCY, NETWORK -->
                            <StackPanel Grid.Column="0" Margin="0,0,8,0">
                                <!-- Card: GPU & Display -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="GRAPHICS &amp; DISPLAY LATENCY" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkGpuAuto" Content="GPU Auto-Optimization (NVIDIA &amp; AMD Driver Tuning)" IsChecked="True"/>
                                        <CheckBox Name="ChkHardwareMsi" Content="Hardware MSI Mode (USB &amp; Network Controllers - Lowest DPC Latency)" IsChecked="True"/>
                                        <CheckBox Name="ChkDisablePowerSaving" Content="Disable USB &amp; Hardware Power Saving (Always Full Power - No Sleep States)" IsChecked="True"/>
                                        <CheckBox Name="ChkMpo" Content="Disable Multiplane Overlay (MPO Fix - Fixes Stutters &amp; Black Screens)" IsChecked="True"/>
                                        <CheckBox Name="ChkMouseCurve" Content="1:1 Linear Mouse Curve (Disables Windows Pointer Acceleration)" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Ultra-Low Latency & Input -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="INPUT &amp; TIMER RESOLUTION" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkInputLatency" Content="8000Hz Polling Rate &amp; Keyboard Response Tuning" IsChecked="True"/>
                                        <CheckBox Name="ChkCsrssPriority" Content="CSRSS Realtime Priority &amp; Max I/O (Thread &amp; Input Latency)" IsChecked="True"/>
                                        <CheckBox Name="ChkCpuSystem" Content="CPU Scheduling &amp; MMCSS Gaming Priority Threads" IsChecked="True"/>
                                        <CheckBox Name="ChkSvcHost" Content="Optimize SvcHost Process Splitting for Physical RAM" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Esports Network Tuning -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="ESPORTS NETWORK ENGINE" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkNetwork" Content="Low-Latency TCP/IP Stack (TCPNoDelay, AckFrequency, CongestionProvider)" IsChecked="True"/>
                                        <CheckBox Name="ChkWifiScan" Content="Disable Wi-Fi Background Auto-Scanning (Eliminates Periodic Lag Spikes)" IsChecked="False"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- COLUMN 2: SYSTEM OPTIMIZATIONS & PRO DEBLOAT -->
                            <StackPanel Grid.Column="1" Margin="8,0,0,0">
                                <!-- Card: Performance Power & Visuals -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="POWER &amp; SYSTEM VISUALS" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkUltimatePower" Content="Unlock Ultimate Performance Power Plan" IsChecked="True"/>
                                        <CheckBox Name="ChkStripVisual" Content="Strip Window Animations &amp; Visual Eye Candy for Max FPS" IsChecked="False"/>
                                        <CheckBox Name="ChkEndTask" Content="Enable Taskbar Right-Click 'End Task' Instant Kill" IsChecked="True"/>
                                        <CheckBox Name="ChkStickyKeys" Content="Disable Sticky Keys &amp; Accessibility Popups" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Background Services & Disk -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="SYSTEM DEBLOAT &amp; STORAGE" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkDebloatServices" Content="Debloat Telemetry, Diagnostics &amp; Background Services" IsChecked="True"/>
                                        <CheckBox Name="ChkDiskIo" Content="Optimize Disk I/O &amp; Disable NTFS Last Access Timestamps" IsChecked="True"/>
                                        <CheckBox Name="ChkJunkTasks" Content="Disable Telemetry &amp; CEIP Scheduled Tasks" IsChecked="True"/>
                                        <CheckBox Name="ChkPrivacy" Content="Harden Windows Privacy &amp; Disable Diagnostic Tracking" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <!-- Beast Mode Banner -->
                                <Border Background="#1F1626" BorderBrush="#FF7700" BorderThickness="1" CornerRadius="6" Padding="14">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Grid.Column="0">
                                            <TextBlock Text="ðŸ”¥ FULL BEAST MODE" FontSize="14" FontWeight="Bold" Foreground="#FF7700"/>
                                            <TextBlock Text="Applies all 20+ competitive low-latency optimizations simultaneously." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0"/>
                                        </StackPanel>
                                        <Button Name="BtnBeastMode" Grid.Column="1" Content="ENGAGE BEAST MODE" Style="{StaticResource OrangeButton}" VerticalAlignment="Center"/>
                                    </Grid>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </ScrollViewer>

                    <!-- ACTION BAR FOR TWEAKS -->
                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Select your desired optimizations above and click Apply. All tweaks are 100% reversible." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <StackPanel Grid.Column="1" Orientation="Horizontal">
                                <Button Name="BtnRevertDefaults" Content="âª Revert to Windows Defaults" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnRunAllTweaks" Content="âš¡ Apply Selected Tweaks" Style="{StaticResource CyanButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 3: MATCH BOOSTER -->
            <TabItem Header="ðŸš€ Match Booster">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Grid Grid.Row="0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <!-- Standby Memory Purger Card -->
                        <Border Grid.Column="0" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="0,0,8,0">
                            <StackPanel>
                                <TextBlock Text="STANDBY MEMORY PURGER" FontWeight="Bold" FontSize="14" Foreground="#00D2FF" Margin="0,0,0,6"/>
                                <TextBlock Text="Clears cached standby list RAM instantly, preventing stutter during gaming matches." Foreground="#94A3B8" FontSize="12" Margin="0,0,0,14"/>
                                <Button Name="BtnPurgeStandby" Content="ðŸ§¹ Purge Standby Memory Now" Style="{StaticResource CyanButton}" Margin="0,0,0,10"/>
                                <TextBlock Text="Uses Win32 memory management API with zero disk wear." FontSize="11" Foreground="#64748B"/>
                            </StackPanel>
                        </Border>

                        <!-- Wi-Fi Ping Spike Shield Card -->
                        <Border Grid.Column="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="8,0,0,0">
                            <StackPanel>
                                <TextBlock Text="WI-FI LATENCY SPIKE SHIELD" FontWeight="Bold" FontSize="14" Foreground="#FF7700" Margin="0,0,0,6"/>
                                <TextBlock Text="Toggles WLAN AutoConfig to halt background network roaming scans." Foreground="#94A3B8" FontSize="12" Margin="0,0,0,14"/>
                                <Button Name="BtnToggleWifiScan" Content="ðŸ“¶ Toggle Wi-Fi AutoConfig" Style="{StaticResource OrangeButton}" Margin="0,0,0,10"/>
                                <TextBlock Text="Enable before entering matches to stop 60-second periodic 200ms ping spikes." FontSize="11" Foreground="#64748B"/>
                            </StackPanel>
                        </Border>
                    </Grid>

                    <!-- Esports Game Priority Hooks Card -->
                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="0,14,0,0">
                        <StackPanel>
                            <TextBlock Text="ESPORTS GAME HIGH-PRIORITY HOOKS (IFEO)" FontWeight="Bold" FontSize="14" Foreground="#00FF88" Margin="0,0,0,6"/>
                            <TextBlock Text="Locks CPU High Priority and GPU High Performance for esports titles permanently via Windows IFEO registry:" Foreground="#94A3B8" FontSize="12" Margin="0,0,0,12"/>

                            <WrapPanel Margin="0,0,0,14">
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Counter-Strike 2 (cs2.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Valorant (VALORANT-Win64-Shipping.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Apex Legends (r5apex.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Fortnite (FortniteClient-Win64-Shipping.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Call of Duty (cod.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Rainbow Six Siege (RainbowSix.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="ðŸŽ¯ Overwatch 2 (Overwatch.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                            </WrapPanel>

                            <Button Name="BtnApplyGameHooks" Content="âš¡ Install Esports Priority Hooks" Style="{StaticResource CyanButton}" HorizontalAlignment="Left"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 4: SYSTEM & HARDENING TOOLS -->
            <TabItem Header="ðŸ›¡ï¸ System &amp; Hardening">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <!-- COLUMN 1: SNAPPY OS & HARDENING -->
                            <StackPanel Grid.Column="0" Margin="0,0,8,0">
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="SECURITY &amp; BLOATWARE MITIGATION" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkBlockWpbt" Content="Block UEFI WPBT Vendor Bloatware Execution" IsChecked="True"/>
                                        <CheckBox Name="ChkBlockPeripheral" Content="Block Peripheral Bloatware Auto-Install (Razer, Armoury Crate)" IsChecked="True"/>
                                        <CheckBox Name="ChkRemoveAi" Content="Purge Windows AI Bloatware (Recall, Copilot, CoreAI)" IsChecked="True"/>
                                        <CheckBox Name="ChkSecurityUpdatesOnly" Content="Security-Only Updates (Defer Feature Builds 2 Years)" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="WINDOWS EXPLORER &amp; DESKTOP" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkClassicContext" Content="Restore Windows 10 Classic Right-Click Menu" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableBing" Content="Disable Start Menu Bing Web Search &amp; Cloud Queries" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableAutoDiscovery" Content="Disable Network File Sharing Auto-Discovery" IsChecked="True"/>
                                        <CheckBox Name="ChkShowExtensions" Content="Show File Extensions &amp; Hidden System Files" IsChecked="True"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- COLUMN 2: ADVANCED KERNEL & SYSTEM POWER TOOLS -->
                            <StackPanel Grid.Column="1" Margin="8,0,0,0">
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="KERNEL &amp; STORAGE HARDENING" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <CheckBox Name="ChkEnableLongPaths" Content="Enable Win32 Long Paths (&gt; 260 Characters)" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableLockScreen" Content="Disable Lock Screen on Wake" IsChecked="True"/>
                                        <CheckBox Name="ChkBsodVerbose" Content="Enable Verbose BSOD Crash Messages" IsChecked="True"/>
                                        <CheckBox Name="ChkDisableReservedStorage" Content="Disable 7GB Reserved Storage" IsChecked="True"/>
                                    </StackPanel>
                                </Border>

                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="16" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="1-CLICK SYSTEM POWER TOOLS" FontWeight="Bold" FontSize="13" Foreground="#00FF88" Margin="0,0,0,10"/>
                                        <Button Name="BtnMasActivate" Content="ðŸ”‘ Microsoft Activation Scripts (MAS 1-Click)" Style="{StaticResource OrangeButton}" Margin="0,0,0,8"/>
                                        <Button Name="BtnRestorePoint" Content="ðŸ›¡ï¸ Create System Restore Point" Style="{StaticResource CyanButton}" Margin="0,0,0,8"/>
                                        <Button Name="BtnRunDiagnostics" Content="ðŸ©º Run System Hardware &amp; Latency Diagnostics" Style="{StaticResource DarkOutlineButton}"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </ScrollViewer>

                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Hardening optimizations protect against OEM bloatware, telemetry, and background throttling." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <Button Name="BtnApplyHardening" Grid.Column="1" Content="âš¡ Apply Hardening Tweaks" Style="{StaticResource CyanButton}"/>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>
        </TabControl>

        <!-- BOTTOM CONSOLE & REAL-TIME LOG AREA -->
        <Border Grid.Row="2" Background="#0C1017" BorderBrush="#26354A" BorderThickness="0,1,0,0" Padding="14,10">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0" Margin="0,0,0,6">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="OUTPUT LOG" FontSize="11" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,8,0"/>
                        <TextBlock Name="TxtStatus" Text="Ready" FontSize="11" Foreground="#94A3B8"/>
                    </StackPanel>
                    <Button Name="BtnClearConsole" Grid.Column="1" Content="Clear Log" Style="{StaticResource CategoryChip}" Margin="0" Padding="8,2"/>
                </Grid>

                <TextBox Name="TxtConsole" Grid.Row="1" Background="#070A0F" Foreground="#00FF88" BorderBrush="#1E293B" BorderThickness="1" FontFamily="Consolas" FontSize="12" IsReadOnly="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" Padding="8" TextWrapping="NoWrap"/>

                <ProgressBar Name="MainProgressBar" Grid.Row="2" Height="4" Background="#161E2B" Foreground="#00D2FF" BorderThickness="0" Margin="0,6,0,0" Value="0" Maximum="100"/>
            </Grid>
        </Border>
    </Grid>
</Window>
'@