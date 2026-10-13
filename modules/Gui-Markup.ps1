<#
================================================================================
  PumpkiN's Modular Suite: Cyberpunk Dark WPF (XAML) UI Markup
================================================================================
#>

$Global:xamlContent = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PumpkiN Ultimate Gaming Optimizer &amp; Software Suite v5.5.0"
    Height="840" Width="1240"
    MinHeight="700" MinWidth="1000"
    WindowStartupLocation="CenterScreen"
    Background="#0F141C"
    Foreground="#F1F5F9"
    FontFamily="Segoe UI Variable Text, Segoe UI, Arial"
    TextOptions.TextFormattingMode="Display"
    TextOptions.TextRenderingMode="ClearType"
    SnapsToDevicePixels="True"
    UseLayoutRounding="True">

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
        <!-- Mini Apply Action Button -->
        <Style x:Key="MiniApplyButton" TargetType="Button">
            <Setter Property="Background" Value="#1E293B"/>
            <Setter Property="Foreground" Value="#00D2FF"/>
            <Setter Property="BorderBrush" Value="#26354A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Padding" Value="9,3"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="3" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#00D2FF"/>
                                <Setter Property="Foreground" Value="#0A0E14"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#0284C7"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <!-- Mini Rollback Action Button -->
        <Style x:Key="MiniRollbackButton" TargetType="Button">
            <Setter Property="Background" Value="#1C141A"/>
            <Setter Property="Foreground" Value="#FF4A70"/>
            <Setter Property="BorderBrush" Value="#4A2635"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Padding" Value="8,3"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="3" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#FF0055"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#FF0055"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#B8003E"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <!-- Device Spec Copy Button Style -->
        <Style x:Key="DeviceCopyButton" TargetType="Button">
            <Setter Property="Background" Value="#1E2838"/>
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Padding" Value="14,4"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#2D3B4E"/>
                                <Setter Property="Foreground" Value="#00D2FF"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#00D2FF"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#161E2B"/>
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
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <Border Width="40" Height="40" CornerRadius="8" Background="#161E2B" BorderBrush="#00D2FF" BorderThickness="1" Margin="0,0,12,0" VerticalAlignment="Center">
                        <Image Name="ImgAppLogo" Width="32" Height="32" VerticalAlignment="Center" HorizontalAlignment="Center" RenderOptions.BitmapScalingMode="HighQuality"/>
                    </Border>
                    <StackPanel>
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="PUMPKIN" FontSize="20" FontWeight="Bold" Foreground="#00D2FF" VerticalAlignment="Center"/>
                            <TextBlock Text=" ULTIMATE OPTIMIZER" FontSize="20" FontWeight="Bold" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                            <Border Background="#FF7700" CornerRadius="3" Padding="6,2" Margin="10,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="v5.5.0" FontSize="11" FontWeight="Bold" Foreground="#0F141C"/>
                            </Border>
                        </StackPanel>
                        <TextBlock Text="Ultra Low-Latency Windows Kernel Engine &amp; 10-Category WinGet Software Suite" FontSize="12" Foreground="#94A3B8" Margin="0,2,0,0"/>
                    </StackPanel>
                </StackPanel>

                <!-- LIVE HARDWARE TELEMETRY HUD -->
                <Border Grid.Column="1" Background="#0A0E14" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,6" Margin="16,0" HorizontalAlignment="Center" VerticalAlignment="Center">
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <StackPanel Orientation="Horizontal" Margin="0,0,14,0" VerticalAlignment="Center">
                            <TextBlock Text="CPU: " FontWeight="Bold" FontSize="11" Foreground="#00D2FF"/>
                            <TextBlock Name="TxtLiveCpu" Text="--%" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                        </StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="0,0,14,0" VerticalAlignment="Center">
                            <TextBlock Text="RAM: " FontWeight="Bold" FontSize="11" Foreground="#00FF88"/>
                            <TextBlock Name="TxtLiveRam" Text="-- GB (--%)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                        </StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="0,0,14,0" VerticalAlignment="Center">
                            <TextBlock Text="PING: " FontWeight="Bold" FontSize="11" Foreground="#FF7700"/>
                            <TextBlock Name="TxtLivePing" Text="-- ms" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                        </StackPanel>
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <TextBlock Text="BOOSTER: " FontWeight="Bold" FontSize="11" Foreground="#A855F7"/>
                            <TextBlock Name="TxtLiveBooster" Text="STANDBY" FontWeight="SemiBold" FontSize="12" Foreground="#94A3B8"/>
                        </StackPanel>
                    </StackPanel>
                </Border>

                <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                    <Button Name="BtnBeastMode" Content="ENGAGE BEAST MODE" Style="{StaticResource OrangeButton}" Margin="0,0,10,0"/>
                    <Button Name="BtnRestorePointTop" Content="Create Restore Point" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                    <Button Name="BtnMasActivateTop" Content="MAS Activation" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                    <Button Name="BtnExitTop" Content="Exit" Style="{StaticResource DarkOutlineButton}"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN TAB CONTROL -->
        <TabControl Grid.Row="1" Background="Transparent" BorderThickness="0" Margin="14,10,14,0">

            <!-- TAB 1: SOFTWARE DOWNLOADER -->
            <TabItem Header="Software Downloader">
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
                                <TextBlock IsHitTestVisible="False" Text="Search 100+ applications (e.g. Brave, Discord, Steam, VS Code)..." VerticalAlignment="Center" Margin="12,0,0,0" Foreground="#64748B" FontSize="13">
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
                                <Button Name="BtnInstallSelected" Content="Install Selected" Style="{StaticResource CyanButton}" Margin="0,0,0,10"/>
                                <Button Name="BtnUninstallSelected" Content="Uninstall Selected" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,10"/>
                                <Button Name="BtnUpgradeAll" Content="Upgrade All (WinGet)" Style="{StaticResource OrangeButton}" Margin="0,0,0,14"/>
                                <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10" Margin="0,0,0,14">
                                    <StackPanel>
                                        <TextBlock Text="EQUICORD CLIENT" FontSize="11" FontWeight="Bold" Foreground="#00D2FF" Margin="0,0,0,4"/>
                                        <TextBlock Text="Enhanced Discord client with 100+ plugins &amp; themes." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,8" TextWrapping="Wrap"/>
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <Button Name="BtnInstallEquicord" Grid.Column="0" Content="Install" Style="{StaticResource CyanButton}" Padding="4,4" FontSize="11" Margin="0,0,3,0"/>
                                            <Button Name="BtnOpenEquicordSite" Grid.Column="1" Content="Website" Style="{StaticResource DarkOutlineButton}" Padding="4,4" FontSize="11" Margin="3,0,0,0"/>
                                        </Grid>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <Separator Grid.Row="1" Background="#26354A" Margin="0,0,0,14"/>

                            <StackPanel Grid.Row="2">
                                <TextBlock Text="SELECTION" FontSize="12" FontWeight="Bold" Foreground="#94A3B8" Margin="0,0,0,8"/>
                                <Button Name="BtnSelectAll" Content="Select Visible" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,8"/>
                                <Button Name="BtnClearAll" Content="Clear Selection" Style="{StaticResource DarkOutlineButton}" Margin="0,0,0,12"/>
                                <TextBlock Name="TxtSelectedCount" Text="0 apps selected" FontSize="12" Foreground="#00D2FF" FontWeight="SemiBold"/>
                            </StackPanel>

                            <Border Grid.Row="3" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10">
                                <TextBlock Text="WinGet installs directly from official vendor repositories with silent parameters." FontSize="11" Foreground="#64748B" TextWrapping="Wrap"/>
                            </Border>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>

                                                <!-- TAB 2: GAMING TWEAKS -->
            <TabItem Header="Gaming Tweaks">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- ROW 0: OPTIMIZATION SCORE DASHBOARD BANNER -->
                    <Border Grid.Row="0" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="8" Padding="14,12" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <!-- Circular Radial Score Gauge -->
                            <Border Name="BorderScoreGauge" Grid.Column="0" Width="84" Height="84" CornerRadius="42" Background="#0C1017" BorderBrush="#00D2FF" BorderThickness="3" VerticalAlignment="Center" Margin="0,0,16,0">
                                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                    <TextBlock Name="TxtScorePercent" Text="100%" FontSize="18" FontWeight="Bold" Foreground="#00FF88" HorizontalAlignment="Center"/>
                                    <TextBlock Name="TxtScoreGrade" Text="A+ Optimal" FontSize="9" FontWeight="SemiBold" Foreground="#94A3B8" HorizontalAlignment="Center"/>
                                    <TextBlock Text="Score" FontSize="8" Foreground="#64748B" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>

                            <!-- Center Info & Badges -->
                            <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                <WrapPanel Margin="0,0,0,6">
                                    <Border Background="#1E293B" CornerRadius="4" Padding="6,2" Margin="0,0,6,0">
                                        <TextBlock Text="[Usability &amp; Shell Features]" FontSize="11" FontWeight="SemiBold" Foreground="#00D2FF"/>
                                    </Border>
                                    <Border Background="#1E293B" CornerRadius="4" Padding="6,2" Margin="0,0,6,0">
                                        <TextBlock Name="TxtSystemSpecBadge" Text="[Windows Optimization Suite]" FontSize="11" Foreground="#CBD5E1"/>
                                    </Border>
                                    <Border Background="#0B2518" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="4" Padding="6,2">
                                        <TextBlock Name="TxtActiveTweakRatio" Text="[Active: 50 / 75]" FontSize="11" FontWeight="Bold" Foreground="#00FF88"/>
                                    </Border>
                                </WrapPanel>

                                <TextBlock Text="Streamline. Optimize. Dominate. 100% reversible live Windows tuning with individual rollbacks." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                <TextBlock Name="TxtScoreSubtitle" Text="[OK] Recommended: Ready   [&lt;] Rollbacks: Ready   [*] 1-Click Control" FontSize="10" Foreground="#64748B" Margin="0,4,0,0"/>
                            </StackPanel>

                            <!-- Right Controls -->
                            <StackPanel Grid.Column="2" VerticalAlignment="Center" Margin="14,0,0,0">
                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,0,6">
                                    <Button Name="BtnFilterRec" Content="Rec" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                    <Button Name="BtnFilterSafe" Content="Safe" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                    <Button Name="BtnFilterAdv" Content="Adv" Style="{StaticResource MiniApplyButton}"/>
                                </StackPanel>
                                <Button Name="BtnApplyUnappliedBanner" Content="Apply Unapplied Only" Style="{StaticResource CyanButton}" Padding="12,6" FontSize="11" Margin="0,0,0,4"/>
                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                    <Button Name="BtnScanSystemStateBanner" Content="Live Audit" Style="{StaticResource DarkOutlineButton}" Padding="8,4" FontSize="10" Margin="0,0,4,0"/>
                                    <Button Name="BtnRevertDefaultsBanner" Content="Rollback All" Style="{StaticResource MiniRollbackButton}" Padding="8,4" FontSize="10"/>
                                </StackPanel>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <!-- COLUMN 1: GPU, LATENCY, NETWORK -->
                            <StackPanel Grid.Column="0" Margin="0,0,8,0">
                                <!-- Card: GPU & Display -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="GRAPHICS &amp; DISPLAY LATENCY" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="GPU Auto-Tuning" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_GpuAuto" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_GpuAuto" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Optimizes NVIDIA and AMD driver settings for maximum frame rates." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_GpuAuto" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_GpuAuto" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Hardware MSI Mode" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_HardwareMsi" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_HardwareMsi" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Switches USB and network adapters to MSI for lowest DPC latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_HardwareMsi" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_HardwareMsi" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable USB Sleep" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DisablePowerSaving" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DisablePowerSaving" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Stops Windows from throttling USB controllers and gaming peripherals." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DisablePowerSaving" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DisablePowerSaving" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable MPO" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_Mpo" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_Mpo" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables Multiplane Overlay to eliminate micro-stutters and black screens." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_Mpo" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_Mpo" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Raw Mouse Input" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_MouseCurve" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_MouseCurve" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables Windows pointer acceleration for true 1:1 sensor tracking." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_MouseCurve" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_MouseCurve" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Ultra-Low Latency & Input -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="INPUT &amp; TIMER RESOLUTION" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="8000Hz Input Tuning" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_InputLatency" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_InputLatency" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Optimizes keyboard buffers and high-polling mouse latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_InputLatency" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_InputLatency" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="CSRSS Realtime I/O" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_CsrssPriority" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_CsrssPriority" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Sets Windows subsystem to Realtime priority for lowest input latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_CsrssPriority" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_CsrssPriority" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="CPU Gaming Quantum" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_CpuSystem" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_CpuSystem" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Prioritizes foreground games and MMCSS multimedia threads." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_CpuSystem" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_CpuSystem" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="SvcHost RAM Splitting" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_SvcHost" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_SvcHost" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Isolates Windows services into dedicated RAM pools for stability." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_SvcHost" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_SvcHost" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Audio DPC & USB Interrupts -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="AUDIO DPC &amp; USB INTERRUPTS" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Low-Latency Audio &amp; Anti-Popping" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_AudioDpc" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_AudioDpc" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="MMCSS Audio High priority, Realtek/HD Audio MSI mode, zero audio drops." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_AudioDpc" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_AudioDpc" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="USB xHCI Thread Priority" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_UsbxHci" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_UsbxHci" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Kernel Thread Priority 31 for USB 3.x controller and 200-depth mouse buffers." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_UsbxHci" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_UsbxHci" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Hardware MSI &amp; Interrupt Report" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Audits real-time MSI mode and IRQ priorities across GPU, USB, Audio, and NIC." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnReport_Interrupts" Grid.Column="1" Content="Audit" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable High-Latency Devices (Device Manager)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DeviceManager" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DeviceManager" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables HPET, AMD SMBus, System Speaker, Kernel Debugger, DMA &amp; Legacy Timers in Device Manager to eliminate DPC latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DeviceManager" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DeviceManager" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Esports Network Engine -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="ESPORTS NETWORK ENGINE" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="TCP/IP Gaming Stack" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_Network" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_Network" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables Nagle algorithm and packet delays for online gaming." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_Network" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_Network" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Wi-Fi Ping Shield" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_WifiScan" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_WifiScan" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Blocks background roaming scans that cause periodic 200ms ping spikes." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_WifiScan" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_WifiScan" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Gaming DNS &amp; Startup Tuning" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_StartupDns" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_StartupDns" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Configures Cloudflare 1.1.1.1 gaming DNS and cleans startup bloat." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_StartupDns" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_StartupDns" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Gaming DNS Benchmark & Fast Switcher -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="GAMING DNS BENCHMARK &amp; FAST SWITCHER" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Benchmark &amp; Auto-Apply Fastest DNS" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Pings Cloudflare, Google, Quad9, AdGuard, OpenDNS (3-sample avg) and applies lowest latency provider." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnBenchmarkDns" Grid.Column="1" Content="Benchmark" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Reset DNS to DHCP Defaults" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Restores automatic router DHCP DNS server addresses across all adapters." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnResetDns" Grid.Column="1" Content="Reset" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- COLUMN 2: SYSTEM OPTIMIZATIONS & PRO DEBLOAT -->
                            <StackPanel Grid.Column="1" Margin="8,0,0,0">
                                <!-- Card: Esports Priority Hooks -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="ESPORTS GAME PRIORITY HOOKS" FontWeight="Bold" FontSize="13" Foreground="#00FF88" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Esports Game Priority Hooks" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_GameHooks" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_GameHooks" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Locks CPU High Priority and GPU High Performance for CS2, Valorant, Apex, PUBG, Fortnite, COD." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_GameHooks" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_GameHooks" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Performance Power & Visuals -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="POWER &amp; SYSTEM VISUALS" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="PumpkiN Esports Ultimate Power Plan" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_UltimatePower" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_UltimatePower" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Activates custom low-latency scheme with 0% core parking, 0ms DPC transition, and USB/PCIe sleep off." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_UltimatePower" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_UltimatePower" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="100% CPU Core Unparking" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_CoreUnpark" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_CoreUnpark" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Unparks all logical CPU cores, forces instant frequency ramp-up, and unmasks core parking in Power Options." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_CoreUnpark" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_CoreUnpark" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Strip Visual Animations" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_StripVisual" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_StripVisual" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Removes desktop animations and window shadows for maximum FPS." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_StripVisual" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_StripVisual" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Taskbar End Task" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_EndTask" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_EndTask" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Adds instant force-close to right-clicked taskbar app icons." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_EndTask" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_EndTask" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Sticky Keys" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_StickyKeys" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_StickyKeys" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Stops annoying accessibility popups when pressing Shift repeatedly." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_StickyKeys" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_StickyKeys" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Compact Window Metrics" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_CompactMetrics" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_CompactMetrics" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="8px thin scrollbars (-120), 1px border (-15), 0px padding, and 10px compact title bar (-150)." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_CompactMetrics" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnReset_CompactMetrics" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <!-- Card: Background Services & Disk -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="SYSTEM DEBLOAT &amp; STORAGE" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Debloat Services" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DebloatServices" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DebloatServices" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables telemetry, diagnostic tracking, and background services." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DebloatServices" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DebloatServices" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Optimize Disk I/O" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DiskIo" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DiskIo" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables NTFS last-access timestamps and optimizes disk buffers." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DiskIo" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DiskIo" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="CompactOS Compression" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_CompactOs" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_CompactOs" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Compresses Windows system binaries using LZX to reclaim 3-6 GB on SSD." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_CompactOs" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_CompactOs" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Take Ownership Menu" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_TakeOwnership" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_TakeOwnership" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Adds a 1-click Take Ownership shortcut to Explorer right-click menu." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_TakeOwnership" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_TakeOwnership" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Junk Tasks" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_JunkTasks" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_JunkTasks" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables CEIP, feedback, and telemetry background scheduled tasks." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_JunkTasks" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_JunkTasks" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Telemetry" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_Privacy" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_Privacy" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Hardens privacy by disabling telemetry and background diagnostics." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_Privacy" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_Privacy" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Deep Cache &amp; Event Cleaner" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Purges Windows Temp, Prefetch, spooler cache, and wipes all Windows Event Logs." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DeepCache" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="GPU Shader &amp; Browser Cache Purge" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Wipes DirectX D3DSCache, NVIDIA DX/GL, AMD DxCache, Discord, and Chrome/Edge caches." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_ShaderCache" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </ScrollViewer>

                    <!-- ACTION BAR FOR TWEAKS -->
                    <Border Grid.Row="2" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Click [Apply] next to any tweak to run it individually, or run all below." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <StackPanel Grid.Column="1" Orientation="Horizontal">
                                <Button Name="BtnScanSystemState" Content="Audit System State" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnApplyUnappliedOnly" Content="Apply Unapplied Only" Style="{StaticResource OrangeButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnClearDeepCacheBar" Content="Deep Cache Cleaner" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnClearUpdateCache" Content="Purge Update Cache" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnInstallDirectXDirect" Content="DirectX (Direct)" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnInstallVcRedistAio" Content="VC++ AIO (Direct)" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnRevertDefaults" Content="Revert to Windows Defaults" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnRunAllTweaks" Content="Apply All Gaming Tweaks" Style="{StaticResource CyanButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 3: MATCH BOOSTER -->
            <TabItem Header="Match Booster">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="0,10,0,0">
                    <StackPanel>
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <!-- Standby Memory Purger Card -->
                            <Border Grid.Column="0" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="0,0,8,0">
                                <StackPanel>
                                    <TextBlock Text="STANDBY MEMORY PURGER" FontWeight="Bold" FontSize="14" Foreground="#00D2FF" Margin="0,0,0,6"/>
                                    <TextBlock Text="Clears cached standby list RAM instantly, preventing stutter during gaming matches." Foreground="#94A3B8" FontSize="12" Margin="0,0,0,14"/>
                                    <Button Name="BtnPurgeStandby" Content="Purge Standby Memory (One-Time Run)" Style="{StaticResource CyanButton}" Margin="0,0,0,14"/>

                                    <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,10" Margin="0,0,0,10">
                                        <StackPanel>
                                            <TextBlock Text="BACKGROUND AUTO-PURGE SCHEDULE" FontWeight="Bold" FontSize="11" Foreground="#00FF88" Margin="0,0,0,6"/>
                                            <TextBlock Text="Set background Task Scheduler auto-clean interval:" FontSize="11" Foreground="#94A3B8" Margin="0,0,0,8"/>
                                            <Grid Margin="0,0,0,8">
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <ComboBox Name="CmbStandbyInterval" SelectedIndex="0" Background="#161E2B" Foreground="#000000" BorderBrush="#26354A" BorderThickness="1" Padding="6,4" VerticalAlignment="Center">
                                                    <ComboBoxItem Content="5 Minutes (Esports Default)" Tag="5"/>
                                                    <ComboBoxItem Content="10 Minutes (Balanced)" Tag="10"/>
                                                    <ComboBoxItem Content="15 Minutes (Low Overhead)" Tag="15"/>
                                                    <ComboBoxItem Content="30 Minutes (Standard)" Tag="30"/>
                                                </ComboBox>
                                                <Button Name="BtnSetStandbySchedule" Grid.Column="1" Content="Activate" Style="{StaticResource MiniApplyButton}" Margin="6,0,0,0" Padding="10,5" VerticalAlignment="Center"/>
                                            </Grid>
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <TextBlock Name="TxtStandbyTaskStatus" Grid.Column="0" Text="Status: Checking..." FontSize="11" Foreground="#94A3B8" VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
                                                <Button Name="BtnRemoveStandbySchedule" Grid.Column="1" Content="Disable" Style="{StaticResource MiniApplyButton}" Padding="10,5" VerticalAlignment="Center"/>
                                            </Grid>
                                        </StackPanel>
                                    </Border>
                                    <TextBlock Text="Uses Win32 memory management API with zero disk wear." FontSize="11" Foreground="#64748B"/>
                                </StackPanel>
                            </Border>

                            <!-- Wi-Fi Ping Spike Shield Card -->
                            <Border Grid.Column="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="8,0,0,0">
                                <StackPanel>
                                    <TextBlock Text="WI-FI LATENCY SPIKE SHIELD" FontWeight="Bold" FontSize="14" Foreground="#FF7700" Margin="0,0,0,6"/>
                                    <TextBlock Text="Toggles WLAN AutoConfig to halt background network roaming scans." Foreground="#94A3B8" FontSize="12" Margin="0,0,0,14"/>
                                    <Button Name="BtnToggleWifiScan" Content="Toggle Wi-Fi AutoConfig" Style="{StaticResource OrangeButton}" Margin="0,0,0,10"/>
                                    <TextBlock Text="Enable before entering matches to stop 60-second periodic 200ms ping spikes." FontSize="11" Foreground="#64748B"/>
                                </StackPanel>
                            </Border>
                        </Grid>

                        <!-- Smart Game Booster Daemon Card -->
                        <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="0,14,0,0">
                            <StackPanel>
                                <Grid Margin="0,0,0,10">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <StackPanel Grid.Column="0" Margin="0,0,14,0">
                                        <TextBlock Text="SMART GAME BOOSTER DAEMON (AUTO-DETECTION ENGINE)" FontWeight="Bold" FontSize="14" Foreground="#A855F7" Margin="0,0,0,4"/>
                                        <TextBlock Text="Watches for 20+ competitive titles (CS2, Valorant, Apex, PUBG, Fortnite, COD, etc.). When a game launches, instantly purges standby RAM, trims background memory hogs (Chrome/Discord/Spotify), locks High CPU priority, and engages Wi-Fi Ping Shield." Foreground="#94A3B8" FontSize="12" TextWrapping="Wrap"/>
                                    </StackPanel>
                                    <Border Grid.Column="1" Background="#0A0E14" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,6" VerticalAlignment="Center">
                                        <TextBlock Name="TxtDaemonStatus" Text="Status: INACTIVE (Stopped)" FontSize="12" FontWeight="Bold" Foreground="#94A3B8"/>
                                    </Border>
                                </Grid>

                                <StackPanel Orientation="Horizontal">
                                    <Button Name="BtnStartGameBooster" Content="Start Smart Booster Daemon" Style="{StaticResource CyanButton}" Margin="0,0,10,0"/>
                                    <Button Name="BtnStopGameBooster" Content="Stop Daemon" Style="{StaticResource DarkOutlineButton}"/>
                                </StackPanel>
                            </StackPanel>
                        </Border>

                        <!-- Esports Game Priority Hooks Card -->
                        <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="18" Margin="0,14,0,0">
                        <StackPanel>
                            <TextBlock Text="ESPORTS GAME HIGH-PRIORITY HOOKS (IFEO)" FontWeight="Bold" FontSize="14" Foreground="#00FF88" Margin="0,0,0,6"/>
                            <TextBlock Text="Locks CPU High Priority and GPU High Performance for esports titles permanently via Windows IFEO registry:" Foreground="#94A3B8" FontSize="12" Margin="0,0,0,12"/>

                            <WrapPanel Margin="0,0,0,14">
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] Counter-Strike 2 (cs2.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] Valorant (VALORANT-Win64-Shipping.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] Apex Legends (r5apex.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] Fortnite (FortniteClient-Win64-Shipping.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] Call of Duty (cod.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] Rainbow Six Siege (RainbowSix.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] Overwatch 2 (Overwatch.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                                <Border Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="10,6" Margin="0,0,8,8">
                                    <TextBlock Text="[>] PUBG (TslGame.exe)" Foreground="#FFFFFF" FontSize="12"/>
                                </Border>
                            </WrapPanel>

                            <Button Name="BtnApplyGameHooks" Content="Install Esports Priority Hooks" Style="{StaticResource CyanButton}" HorizontalAlignment="Left"/>
                        </StackPanel>
                    </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>

                                    <!-- TAB 4: SYSTEM & HARDENING TOOLS -->
            <TabItem Header="System &amp; Hardening">
                <Grid Margin="0,10,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- TAB 4 SCORE DASHBOARD BANNER -->
                    <Border Grid.Row="0" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="8" Padding="14,12" Margin="0,0,0,12">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <Border Name="BorderScoreGaugeTab4" Grid.Column="0" Width="84" Height="84" CornerRadius="42" Background="#0C1017" BorderBrush="#00FF88" BorderThickness="3" VerticalAlignment="Center" Margin="0,0,16,0">
                                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                    <TextBlock Name="TxtScorePercentTab4" Text="100%" FontSize="18" FontWeight="Bold" Foreground="#00FF88" HorizontalAlignment="Center"/>
                                    <TextBlock Name="TxtScoreGradeTab4" Text="A+ Optimal" FontSize="9" FontWeight="SemiBold" Foreground="#94A3B8" HorizontalAlignment="Center"/>
                                    <TextBlock Text="Score" FontSize="8" Foreground="#64748B" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>

                            <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                <WrapPanel Margin="0,0,0,6">
                                    <Border Background="#1E293B" CornerRadius="4" Padding="6,2" Margin="0,0,6,0">
                                        <TextBlock Text="[Security &amp; Privacy Shield]" FontSize="11" FontWeight="SemiBold" Foreground="#00FF88"/>
                                    </Border>
                                    <Border Background="#1E293B" CornerRadius="4" Padding="6,2" Margin="0,0,6,0">
                                        <TextBlock Text="[Windows 11 Hardening Suite]" FontSize="11" Foreground="#CBD5E1"/>
                                    </Border>
                                    <Border Background="#0B2518" BorderBrush="#00FF88" BorderThickness="1" CornerRadius="4" Padding="6,2">
                                        <TextBlock Name="TxtActiveTweakRatioTab4" Text="[Active: 50 / 75]" FontSize="11" FontWeight="Bold" Foreground="#00FF88"/>
                                    </Border>
                                </WrapPanel>
                                <TextBlock Text="Enterprise-grade telemetry strip, OEM bloatware immunization, and Windows 11 desktop refinements." FontSize="11" Foreground="#94A3B8" TextWrapping="Wrap"/>
                                <TextBlock Text="[OK] Symmetrical 1-Click Rollbacks for Every Individual Tweak" FontSize="10" Foreground="#64748B" Margin="0,4,0,0"/>
                            </StackPanel>

                            <StackPanel Grid.Column="2" VerticalAlignment="Center" Margin="14,0,0,0">
                                <Button Name="BtnApplyUnappliedHardeningBanner" Content="Apply Unapplied Only" Style="{StaticResource OrangeButton}" Padding="12,6" FontSize="11" Margin="0,0,0,4"/>
                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                    <Button Name="BtnScanSystemStateTab4Banner" Content="Live Audit" Style="{StaticResource DarkOutlineButton}" Padding="8,4" FontSize="10" Margin="0,0,4,0"/>
                                    <Button Name="BtnRevertDefaultsTab4" Content="Rollback All" Style="{StaticResource MiniRollbackButton}" Padding="8,4" FontSize="10"/>
                                </StackPanel>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <!-- COLUMN 1: SNAPPY OS & HARDENING -->
                            <StackPanel Grid.Column="0" Margin="0,0,8,0">
                                <!-- Card: Windows 11 Exclusives & Shell Usability -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="WINDOWS 11 EXCLUSIVES &amp; SHELL USABILITY" FontWeight="Bold" FontSize="13" Foreground="#00FF88" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable VBS / HVCI Security" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_VbsSecurity" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_VbsSecurity" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Turns off hypervisor-protected code integrity to reclaim 5-15% gaming CPU latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_VbsSecurity" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_VbsSecurity" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Align Taskbar to Left" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_TaskbarLeft" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_TaskbarLeft" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Moves the Windows 11 taskbar icons from center to classic left alignment." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_TaskbarLeft" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_TaskbarLeft" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Recommended in Start" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_RecommendedStart" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_RecommendedStart" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Removes the bulky Recommended section in Start Menu for a cleaner layout." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_RecommendedStart" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_RecommendedStart" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Taskbar Chat (Teams)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_TaskbarChat" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_TaskbarChat" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Hides and unloads the integrated Microsoft Teams Chat icon from taskbar." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_TaskbarChat" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_TaskbarChat" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Files Compact View Mode" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_FilesCompact" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_FilesCompact" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Enables compact row spacing in File Explorer for denser file navigation." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_FilesCompact" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_FilesCompact" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Edge Discover &amp; Sidebar" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_EdgeDiscover" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_EdgeDiscover" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Removes the Bing Copilot button and unwanted side toolbar from Edge." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_EdgeDiscover" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_EdgeDiscover" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Add 'Copy/Move To' Context Menu" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_CopyMoveMenu" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_CopyMoveMenu" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Adds Copy To Folder &amp; Move To Folder directly in right-click explorer menu." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_CopyMoveMenu" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_CopyMoveMenu" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Windows System Dark Mode" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_SystemDarkMode" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_SystemDarkMode" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Enforces dark theme across Windows Shell and apps without Windows activation." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_SystemDarkMode" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_SystemDarkMode" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Window Shake (Aero)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_WindowShake" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_WindowShake" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Prevents accidentally minimizing all background windows when shaking a window." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_WindowShake" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_WindowShake" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Enable Verbose Logon" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_VerboseLogon" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_VerboseLogon" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Displays detailed startup and logoff stages on screen instead of generic dots." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_VerboseLogon" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_VerboseLogon" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="SECURITY &amp; BLOATWARE MITIGATION" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Block WPBT Bloat" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_BlockWpbt" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_BlockWpbt" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Prevents motherboard UEFI from auto-installing OEM bloatware." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_BlockWpbt" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_BlockWpbt" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Block Peripheral Bloat" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_BlockPeripheral" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_BlockPeripheral" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Blocks auto-install of Razer Synapse, Armoury Crate, and vendor tools." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_BlockPeripheral" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_BlockPeripheral" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Purge Windows AI" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_RemoveAi" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_RemoveAi" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Removes Recall, Copilot, and CoreAI background services." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_RemoveAi" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_RemoveAi" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Security-Only Updates" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_SecurityUpdatesOnly" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_SecurityUpdatesOnly" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Defers feature upgrade builds while keeping security patches active." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_SecurityUpdatesOnly" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_SecurityUpdatesOnly" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="WINDOWS EXPLORER &amp; DESKTOP" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Classic Right-Click" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_ClassicContext" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_ClassicContext" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Restores the classic Windows 10 right-click menu on Windows 11." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_ClassicContext" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_ClassicContext" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Web Search" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DisableBing" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DisableBing" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Stops Start Menu from sending keystrokes to Bing web search." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DisableBing" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DisableBing" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Auto-Discovery" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DisableAutoDiscovery" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DisableAutoDiscovery" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Halts background network broadcast polling for local file shares." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DisableAutoDiscovery" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DisableAutoDiscovery" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Show File Extensions" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_ShowExtensions" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_ShowExtensions" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Shows file extensions (.exe, .ps1) and hidden system files." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_ShowExtensions" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_ShowExtensions" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Pop Cat Recycle Bin" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Changes Desktop Recycle Bin to Pop Cat (open when full, closed when empty)." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_RecycleBinIcon" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,6,0"/>
                                                    <Button Name="BtnReset_RecycleBinIcon" Content="Default" Style="{StaticResource MiniApplyButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable All Windows Ads" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DisableAds" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DisableAds" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Kills Lock Screen ads, Start suggestions, Explorer sync ads, and Settings promotions." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DisableAds" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnReset_DisableAds" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Remove Shortcut Arrows" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_NoShortcutArrows" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_NoShortcutArrows" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Removes shortcut arrow badge overlays for clean desktop icons (No Arrow)." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_NoShortcutArrows" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnReset_ShortcutArrows" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- COLUMN 2: ADVANCED KERNEL & SYSTEM POWER TOOLS -->
                            <StackPanel Grid.Column="1" Margin="8,0,0,0">
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="KERNEL &amp; STORAGE HARDENING" FontWeight="Bold" FontSize="13" Foreground="#FF7700" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Enable Long Paths" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_EnableLongPaths" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_EnableLongPaths" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Removes the 260-character file path limit for modding and dev tools." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_EnableLongPaths" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_EnableLongPaths" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Lock Screen" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DisableLockScreen" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DisableLockScreen" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Skips the swipe-up lock screen directly to the password prompt." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DisableLockScreen" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DisableLockScreen" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Verbose BSOD" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_BsodVerbose" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_BsodVerbose" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Enables detailed crash diagnostic text on blue screens." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_BsodVerbose" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_BsodVerbose" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Reclaim Reserved Storage" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DisableReservedStorage" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DisableReservedStorage" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables 7GB of reserved update storage and returns it to drive C:." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DisableReservedStorage" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DisableReservedStorage" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Turn Off BitLocker Permanently" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_BitLocker" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_BitLocker" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Permanently disables BitLocker device encryption, stops BDESVC service, decrypts active drives, and blocks auto-encryption." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_BitLocker" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_BitLocker" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>

                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="1-CLICK SYSTEM POWER TOOLS" FontWeight="Bold" FontSize="13" Foreground="#00FF88" Margin="0,0,0,10"/>
                                        <Button Name="BtnMasActivate" Content="Microsoft Activation Scripts (MAS 1-Click)" Style="{StaticResource OrangeButton}" Margin="0,0,0,8"/>
                                        <Button Name="BtnRestorePoint" Content="Create System Restore Point" Style="{StaticResource CyanButton}" Margin="0,0,0,8"/>
                                        <Button Name="BtnRunDiagnostics" Content="Run System Hardware &amp; Latency Diagnostics" Style="{StaticResource DarkOutlineButton}"/>
                                    </StackPanel>
                                </Border>

                                <!-- Card: 1-Click Custom Gaming Cursors Manager -->
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <Grid Margin="0,0,0,10">
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="Auto"/>
                                            </Grid.ColumnDefinitions>
                                            <StackPanel Grid.Column="0">
                                                <TextBlock Text="CUSTOM GAMING CURSORS (23 PACKS)" FontWeight="Bold" FontSize="13" Foreground="#00FF88"/>
                                                <TextBlock Text="Instant live 1-click cursor schemes from Cursors folder without reboot." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0"/>
                                            </StackPanel>
                                            <Border Grid.Column="1" Background="#0C1017" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="8,3" VerticalAlignment="Center">
                                                <TextBlock Name="TxtActiveCursorScheme" Text="Active: Windows Default" FontSize="10" FontWeight="SemiBold" Foreground="#00D2FF"/>
                                            </Border>
                                        </Grid>

                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,10">
                                            <Grid>
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="Auto"/>
                                                    <RowDefinition Height="Auto"/>
                                                </Grid.RowDefinitions>
                                                <Grid Grid.Row="0" Margin="0,0,0,8">
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="*"/>
                                                        <ColumnDefinition Width="Auto"/>
                                                        <ColumnDefinition Width="Auto"/>
                                                    </Grid.ColumnDefinitions>
                                                    <ComboBox Name="CmbCursorSchemes" Grid.Column="0" Height="30" Background="#161E2B" Foreground="#FFFFFF" BorderBrush="#26354A" Margin="0,0,8,0" VerticalContentAlignment="Center" FontSize="12"/>
                                                    <Button Name="BtnInstallCursor" Grid.Column="1" Content="Install Cursor" Style="{StaticResource CyanButton}" Padding="14,5" FontSize="11" Margin="0,0,6,0"/>
                                                    <Button Name="BtnRestoreCursor" Grid.Column="2" Content="Default Cursors" Style="{StaticResource DarkOutlineButton}" Padding="12,5" FontSize="11"/>
                                                </Grid>
                                                <TextBlock Grid.Row="1" Text="Select from 23 animated and precision schemes (DIM v3.2, Android Material, Neon, Crosshair, etc.). Instant broadcast." FontSize="11" Foreground="#64748B"/>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>
                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="TRAFFICMONITOR &amp; TASKBAR TELEMETRY" FontWeight="Bold" FontSize="13" Foreground="#A855F7" Margin="0,0,0,6"/>
                                        <TextBlock Text="Real-time CPU/RAM/Net taskbar monitor with MiSans typography and custom config preset." FontSize="11" Foreground="#94A3B8" Margin="0,0,0,10" TextWrapping="Wrap"/>
                                        <Grid Margin="0,0,0,8">
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <Button Name="BtnInstallTrafficMonitor" Grid.Column="0" Content="Download &amp; Install (x64)" Style="{StaticResource CyanButton}" Margin="0,0,4,0"/>
                                            <Button Name="BtnInstallMiSansFonts" Grid.Column="1" Content="Install MiSans Fonts" Style="{StaticResource DarkOutlineButton}" Margin="4,0,0,0"/>
                                        </Grid>
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <Button Name="BtnApplyTrafficMonitorConfig" Grid.Column="0" Content="Apply Custom config.ini" Style="{StaticResource DarkOutlineButton}" Margin="0,0,4,0"/>
                                            <Button Name="BtnLaunchTrafficMonitor" Grid.Column="1" Content="Launch TrafficMonitor" Style="{StaticResource OrangeButton}" Margin="4,0,0,0"/>
                                        </Grid>
                                    </StackPanel>
                                </Border>

                                <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="ADVANCED PRIVACY &amp; APP TELEMETRY" FontWeight="Bold" FontSize="13" Foreground="#00D2FF" Margin="0,0,0,10"/>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable App Telemetry (All)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_AppTelemetry" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_AppTelemetry" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Kills telemetry reporting in Edge, Chrome, Firefox, Visual Studio, and Nvidia drivers." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_AppTelemetry" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_AppTelemetry" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Bluetooth Advertising" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_BluetoothAdvertising" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_BluetoothAdvertising" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Stops broadcasting PC existence to nearby wireless Bluetooth devices." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_BluetoothAdvertising" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_BluetoothAdvertising" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable CDP Services" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_CdpServices" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_CdpServices" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables Connected Devices Platform background sync and tracking daemons." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_CdpServices" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_CdpServices" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Diagnostic Toasts" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DiagnosticsToasts" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DiagnosticsToasts" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Suppresses annoying Security and Maintenance pop-up toasts in action center." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DiagnosticsToasts" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DiagnosticsToasts" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Typing &amp; Ink Telemetry" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_TextInputCollection" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_TextInputCollection" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Blocks transmission of keystroke samples and handwriting patterns to cloud." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_TextInputCollection" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_TextInputCollection" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable Cloud Clipboard Sync" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_ClipboardSync" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_ClipboardSync" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Stops copied passwords and text from synchronizing across foreign devices." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_ClipboardSync" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_ClipboardSync" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Disable SMBv1 (WannaCry Shield)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_SmbV1" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_SmbV1" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Disables insecure legacy SMB 1.0 protocol to seal critical ransomware vectors." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_SmbV1" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_SmbV1" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Exclude Drivers from WU" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_DriverUpdatesExcluded" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_DriverUpdatesExcluded" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Blocks Windows Update from overwriting custom graphics and audio drivers." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_DriverUpdatesExcluded" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_DriverUpdatesExcluded" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <StackPanel Orientation="Horizontal">
                                                        <TextBlock Text="Optimize System Timeouts (0ms)" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                        <Border Name="Badge_SystemTimeouts" Background="#0F141C" BorderBrush="#26354A" BorderThickness="1" CornerRadius="3" Padding="5,1" Margin="8,0,0,0" VerticalAlignment="Center">
                                                            <TextBlock Name="TxtBadge_SystemTimeouts" Text="Needed" FontSize="9" FontWeight="Bold" Foreground="#00D2FF"/>
                                                        </Border>
                                                    </StackPanel>
                                                    <TextBlock Text="Zeros menu delay (0ms) and shortens hung app shutdown wait to 2 seconds." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                                    <Button Name="BtnApply_SystemTimeouts" Content="Apply" Style="{StaticResource MiniApplyButton}" Margin="0,0,4,0"/>
                                                    <Button Name="BtnRollback_SystemTimeouts" Content="Rollback" Style="{StaticResource MiniRollbackButton}"/>
                                                </StackPanel>
                                            </Grid>
                                        </Border>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </Grid>
                    </ScrollViewer>

                    <Border Grid.Row="2" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Click [Apply] next to any hardening tweak, or apply all below." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <StackPanel Grid.Column="1" Orientation="Horizontal">
                                <Button Name="BtnScanSystemStateTab4" Content="Audit System State" Style="{StaticResource DarkOutlineButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnApplyUnappliedHardening" Content="Apply Unapplied Hardening" Style="{StaticResource OrangeButton}" Margin="0,0,10,0"/>
                                <Button Name="BtnApplyHardening" Content="Apply All Hardening" Style="{StaticResource CyanButton}"/>
                            </StackPanel>
                        </Grid>
                    </Border>
                </Grid>
            </TabItem>

            <!-- TAB 5: DEVICE (SPECIFICATIONS & SYSTEM PROFILE) -->
            <TabItem Header="Device">
                <Grid Margin="0,10,0,0">
                    <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                        <StackPanel Margin="0,0,10,10">
                            <!-- DEVICE MASTER BANNER CARD -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="8" Padding="18,14" Margin="0,0,0,12">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="Auto"/>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <!-- Laptop / Monitor Vector Path Icon -->
                                    <Path Grid.Column="0" Data="M 4 8 L 28 8 A 2 2 0 0 1 30 10 L 30 20 A 2 2 0 0 1 28 22 L 4 22 A 2 2 0 0 1 2 20 L 2 10 A 2 2 0 0 1 4 8 Z M 0 24 L 32 24 L 32 26 L 0 26 Z" Stroke="#00D2FF" StrokeThickness="1.5" Fill="Transparent" Width="36" Height="36" VerticalAlignment="Center" Margin="0,0,16,0"/>
                                    <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                        <TextBlock Name="TxtDev_CompName" Text="DEVICE" FontSize="20" FontWeight="Bold" Foreground="#FFFFFF"/>
                                        <TextBlock Name="TxtDev_SubTitle" Text="Windows | CPU | RAM" FontSize="12" Foreground="#94A3B8" Margin="0,3,0,0"/>
                                    </StackPanel>
                                    <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                                        <Button Name="BtnRefreshDeviceSpecs" Content="Refresh" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                        <Button Name="BtnCopyAllDeviceSpecs" Content="Copy All Specs" Style="{StaticResource CyanButton}" Padding="16,5" FontSize="11"/>
                                    </StackPanel>
                                </Grid>
                            </Border>

                            <!-- 1. OPERATING SYSTEM -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Margin="0,0,0,8" Padding="14,10">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <Path Data="M 12 2 A 10 10 0 1 0 22 12 A 10 10 0 0 0 12 2 Z M 12 7 A 5 5 0 1 0 17 12 A 5 5 0 0 0 12 7 Z M 12 10 A 2 2 0 1 1 10 12 A 2 2 0 0 1 12 10 Z" Stroke="#00D2FF" StrokeThickness="1.2" Fill="Transparent" Width="18" Height="18" Margin="0,0,12,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="Operating System" FontWeight="SemiBold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnCopy_DevOs" Content="Copy" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                            <Button Name="BtnToggle_DevOs" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" FontSize="11" Width="26" Height="26" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevOs" Margin="30,12,0,4">
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="OS Name: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Version: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsVersion" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Build Number: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsBuild" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Architecture: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsArch" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Install Date: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsInstallDate" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Registered User: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsUser" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Windows Directory: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsWinDir" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="System Directory: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsSysDir" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Last Boot Up Time: " Foreground="#FFFFFF"/><Run Name="TxtDev_OsBootTime" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- 2. PROCESSOR -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Margin="0,0,0,8" Padding="14,10">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <Path Data="M 4 4 L 20 4 L 20 20 L 4 20 Z M 7 1 L 7 4 M 12 1 L 12 4 M 17 1 L 17 4 M 7 20 L 7 23 M 12 20 L 12 23 M 17 20 L 17 23 M 1 7 L 4 7 M 1 12 L 4 12 M 1 17 L 4 17 M 20 7 L 23 7 M 20 12 L 23 12 M 20 17 L 23 17" Stroke="#00D2FF" StrokeThickness="1.2" Fill="Transparent" Width="18" Height="18" Margin="0,0,12,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="Processor" FontWeight="SemiBold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnCopy_DevCpu" Content="Copy" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                            <Button Name="BtnToggle_DevCpu" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" FontSize="11" Width="26" Height="26" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevCpu" Margin="30,12,0,4">
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Name: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Manufacturer: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuManufacturer" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Architecture: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuArchitecture" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Cores: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuCores" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Logical Processors: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuLogical" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Max Speed: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuMaxSpeed" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Socket Designation: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuSocket" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="L2 Cache Size: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuL2" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="L3 Cache Size: " Foreground="#FFFFFF"/><Run Name="TxtDev_CpuL3" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- 3. GRAPHICS -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Margin="0,0,0,8" Padding="14,10">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <Path Data="M 2 6 L 22 6 L 22 18 L 2 18 Z M 6 10 A 3 3 0 1 0 6 14 A 3 3 0 0 0 6 10 Z M 14 10 A 3 3 0 1 0 14 14 A 3 3 0 0 0 14 10 Z M 4 18 L 4 22 L 8 22 L 8 18" Stroke="#00D2FF" StrokeThickness="1.2" Fill="Transparent" Width="18" Height="18" Margin="0,0,12,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="Graphics" FontWeight="SemiBold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnCopy_DevGpu" Content="Copy" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                            <Button Name="BtnToggle_DevGpu" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" FontSize="11" Width="26" Height="26" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevGpu" Margin="30,12,0,4">
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Name: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Manufacturer: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuManufacturer" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Driver Version: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuDriverVersion" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Driver Date: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuDriverDate" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="VRAM: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuVram" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Resolution: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuResolution" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Refresh Rate: " Foreground="#FFFFFF"/><Run Name="TxtDev_GpuRefreshRate" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- 4. RAM -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Margin="0,0,0,8" Padding="14,10">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <Path Data="M 2 8 L 22 8 L 22 16 L 2 16 Z M 4 16 L 4 18 M 7 16 L 7 18 M 10 16 L 10 18 M 14 16 L 14 18 M 17 16 L 17 18 M 20 16 L 20 18 M 5 10 L 9 10 L 9 14 L 5 14 Z M 12 10 L 16 10 L 16 14 L 12 14 Z" Stroke="#00D2FF" StrokeThickness="1.2" Fill="Transparent" Width="18" Height="18" Margin="0,0,12,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="RAM" FontWeight="SemiBold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnCopy_DevRam" Content="Copy" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                            <Button Name="BtnToggle_DevRam" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" FontSize="11" Width="26" Height="26" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevRam" Margin="30,12,0,4">
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Total Installed: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamTotal" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Usable Memory: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamUsable" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Speed: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamSpeed" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Manufacturer: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamManufacturer" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Part Number: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamPartNumber" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Slots Configured: " Foreground="#FFFFFF"/><Run Name="TxtDev_RamSlots" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- 5. STORAGE -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Margin="0,0,0,8" Padding="14,10">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <Path Data="M 2 8 L 22 8 L 22 16 L 2 16 Z M 17 12 A 1 1 0 1 0 19 12 A 1 1 0 0 0 17 12 Z M 5 12 L 13 12" Stroke="#00D2FF" StrokeThickness="1.2" Fill="Transparent" Width="18" Height="18" Margin="0,0,12,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="Storage" FontWeight="SemiBold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnCopy_DevStorage" Content="Copy" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                            <Button Name="BtnToggle_DevStorage" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" FontSize="11" Width="26" Height="26" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevStorage" Margin="30,12,0,4">
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Physical Disks: " Foreground="#FFFFFF"/><Run Name="TxtDev_StorageDisks" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Volumes &amp; Partitions: " Foreground="#FFFFFF"/><Run Name="TxtDev_StorageVolumes" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- 6. NETWORK -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Margin="0,0,0,8" Padding="14,10">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <Path Data="M 2 4 L 22 4 L 22 16 L 2 16 Z M 12 16 L 12 20 M 6 20 L 18 20" Stroke="#00D2FF" StrokeThickness="1.2" Fill="Transparent" Width="18" Height="18" Margin="0,0,12,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="Network" FontWeight="SemiBold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnCopy_DevNet" Content="Copy" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                            <Button Name="BtnToggle_DevNet" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" FontSize="11" Width="26" Height="26" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevNet" Margin="30,12,0,4">
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Adapter Name: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Description: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetDesc" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="MAC Address: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetMac" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Link Speed: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetSpeed" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="IPv4 Address: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetIp" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Status: " Foreground="#FFFFFF"/><Run Name="TxtDev_NetStatus" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                            <!-- 7. BATTERY -->
                            <Border Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Margin="0,0,0,8" Padding="14,10">
                                <StackPanel>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <Path Data="M 2 6 L 18 6 L 18 18 L 2 18 Z M 18 10 L 21 10 L 21 14 L 18 14 Z M 5 9 L 9 9 L 9 15 L 5 15 Z M 11 9 L 15 9 L 15 15 L 11 15 Z" Stroke="#00D2FF" StrokeThickness="1.2" Fill="Transparent" Width="18" Height="18" Margin="0,0,12,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="Battery" FontWeight="SemiBold" FontSize="13" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                                        </StackPanel>
                                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                                            <Button Name="BtnCopy_DevBattery" Content="Copy" Style="{StaticResource DeviceCopyButton}" Margin="0,0,8,0"/>
                                            <Button Name="BtnToggle_DevBattery" Content="v" Background="Transparent" Foreground="#94A3B8" BorderThickness="0" FontSize="11" Width="26" Height="26" Cursor="Hand"/>
                                        </StackPanel>
                                    </Grid>
                                    <StackPanel Name="Panel_DevBattery" Margin="30,12,0,4">
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Power Status: " Foreground="#FFFFFF"/><Run Name="TxtDev_BatteryStatus" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Battery Device: " Foreground="#FFFFFF"/><Run Name="TxtDev_BatteryName" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                        <TextBlock Margin="0,2" FontSize="12"><Run FontWeight="Bold" Text="Charge Level: " Foreground="#FFFFFF"/><Run Name="TxtDev_BatteryPercent" Text="Loading..." Foreground="#94A3B8"/></TextBlock>
                                    </StackPanel>
                                </StackPanel>
                            </Border>

                        </StackPanel>
                    </ScrollViewer>
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

function Get-OptimizerXamlMarkup {
    return $Global:xamlContent
}
