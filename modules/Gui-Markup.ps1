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
                    <Image Name="ImgAppLogo" Width="36" Height="36" Margin="0,0,12,0" VerticalAlignment="Center" RenderOptions.BitmapScalingMode="HighQuality"/>
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
                                                    <TextBlock Text="GPU Auto-Tuning" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Optimizes NVIDIA and AMD driver settings for maximum frame rates." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_GpuAuto" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Hardware MSI Mode" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Switches USB and network adapters to MSI for lowest DPC latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_HardwareMsi" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable USB Sleep" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Stops Windows from throttling USB controllers and gaming peripherals." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DisablePowerSaving" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable MPO" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Disables Multiplane Overlay to eliminate micro-stutters and black screens." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_Mpo" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Raw Mouse Input" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Disables Windows pointer acceleration for true 1:1 sensor tracking." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_MouseCurve" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="8000Hz Input Tuning" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Optimizes keyboard buffers and high-polling mouse latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_InputLatency" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="CSRSS Realtime I/O" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Sets Windows subsystem to Realtime priority for lowest input latency." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_CsrssPriority" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="CPU Gaming Quantum" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Prioritizes foreground games and MMCSS multimedia threads." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_CpuSystem" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="SvcHost RAM Splitting" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Isolates Windows services into dedicated RAM pools for stability." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_SvcHost" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="Low-Latency Audio &amp; Anti-Popping" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="MMCSS Audio High priority, Realtek/HD Audio MSI mode, zero audio drops." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_AudioDpc" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="USB xHCI Thread Priority" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Kernel Thread Priority 31 for USB 3.x controller and 200-depth mouse buffers." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_UsbxHci" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="TCP/IP Gaming Stack" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Disables Nagle algorithm and packet delays for online gaming." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_Network" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Wi-Fi Ping Shield" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Blocks background roaming scans that cause periodic 200ms ping spikes." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_WifiScan" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Gaming DNS &amp; Startup Tuning" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Configures Cloudflare 1.1.1.1 gaming DNS and cleans startup bloat." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_StartupDns" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="Esports Game Priority Hooks" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Locks CPU High Priority and GPU High Performance for CS2, Valorant, Apex, Fortnite, COD." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_GameHooks" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="PumpkiN Esports Ultimate Power Plan" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Activates custom low-latency scheme with 0% core parking, 0ms DPC transition, and USB/PCIe sleep off." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_UltimatePower" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="100% CPU Core Unparking" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Unparks all logical CPU cores, forces instant frequency ramp-up, and unmasks core parking in Power Options." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_CoreUnpark" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Strip Visual Animations" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Removes desktop animations and window shadows for maximum FPS." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_StripVisual" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Taskbar End Task" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Adds instant force-close to right-clicked taskbar app icons." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_EndTask" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable Sticky Keys" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Stops annoying accessibility popups when pressing Shift repeatedly." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_StickyKeys" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="Debloat Services" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Disables telemetry, diagnostic tracking, and background services." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DebloatServices" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Optimize Disk I/O" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Disables NTFS last-access timestamps and optimizes disk buffers." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DiskIo" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="CompactOS Compression" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Compresses Windows system binaries using LZX to reclaim 3-6 GB on SSD." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_CompactOs" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Take Ownership Menu" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Adds a 1-click Take Ownership shortcut to Explorer right-click menu." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_TakeOwnership" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable Junk Tasks" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Disables CEIP, feedback, and telemetry background scheduled tasks." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_JunkTasks" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable Telemetry" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Hardens privacy by disabling telemetry and background diagnostics." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_Privacy" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Click [Apply] next to any tweak to run it individually, or run all below." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <StackPanel Grid.Column="1" Orientation="Horizontal">
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
                                        <TextBlock Text="Watches for 20+ competitive titles (CS2, Valorant, Apex, Fortnite, COD, etc.). When a game launches, instantly purges standby RAM, trims background memory hogs (Chrome/Discord/Spotify), locks High CPU priority, and engages Wi-Fi Ping Shield." Foreground="#94A3B8" FontSize="12" TextWrapping="Wrap"/>
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
                                                    <TextBlock Text="Block WPBT Bloat" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Prevents motherboard UEFI from auto-installing OEM bloatware." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_BlockWpbt" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Block Peripheral Bloat" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Blocks auto-install of Razer Synapse, Armoury Crate, and vendor tools." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_BlockPeripheral" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Purge Windows AI" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Removes Recall, Copilot, and CoreAI background services." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_RemoveAi" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Security-Only Updates" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Defers feature upgrade builds while keeping security patches active." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_SecurityUpdatesOnly" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="Classic Right-Click" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Restores the classic Windows 10 right-click menu on Windows 11." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_ClassicContext" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable Web Search" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Stops Start Menu from sending keystrokes to Bing web search." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DisableBing" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable Auto-Discovery" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Halts background network broadcast polling for local file shares." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DisableAutoDiscovery" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Show File Extensions" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Shows file extensions (.exe, .ps1) and hidden system files." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_ShowExtensions" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                                                    <TextBlock Text="Enable Long Paths" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Removes the 260-character file path limit for modding and dev tools." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_EnableLongPaths" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Disable Lock Screen" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Skips the swipe-up lock screen directly to the password prompt." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DisableLockScreen" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Verbose BSOD" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Enables detailed crash diagnostic text on blue screens." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_BsodVerbose" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <Border Background="#121822" BorderBrush="#26354A" BorderThickness="1" CornerRadius="4" Padding="12,7" Margin="0,0,0,6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="Auto"/>
                                                </Grid.ColumnDefinitions>
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center" Margin="0,0,12,0">
                                                    <TextBlock Text="Reclaim Reserved Storage" FontWeight="SemiBold" FontSize="12" Foreground="#FFFFFF"/>
                                                    <TextBlock Text="Disables 7GB of reserved update storage and returns it to drive C:." FontSize="11" Foreground="#94A3B8" Margin="0,2,0,0" TextWrapping="Wrap"/>
                                                </StackPanel>
                                                <Button Name="BtnApply_DisableReservedStorage" Grid.Column="1" Content="Apply" Style="{StaticResource MiniApplyButton}" VerticalAlignment="Center"/>
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
                            </StackPanel>
                        </Grid>
                    </ScrollViewer>

                    <Border Grid.Row="1" Background="#161E2B" BorderBrush="#26354A" BorderThickness="1" CornerRadius="6" Padding="14,10" Margin="0,10,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Click [Apply] next to any hardening tweak, or apply all below." VerticalAlignment="Center" Foreground="#94A3B8" FontSize="12"/>
                            <Button Name="BtnApplyHardening" Grid.Column="1" Content="Apply All Hardening" Style="{StaticResource CyanButton}"/>
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